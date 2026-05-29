# Terraform Automation Setup — EZ-FIT

This document covers everything needed to use the `terraform.yml` GitHub Actions workflow
that automates Terraform plan (on PRs) and apply (on main merges).

---

## Why Remote State Is Needed

By default Terraform stores state in a local `terraform.tfstate` file. This breaks in CI/CD
because every GitHub Actions runner is ephemeral — a fresh runner cannot read the state left
by a previous run. Without shared state, Terraform cannot determine what already exists in
Azure and will try to create resources that are already there, causing errors.

An **azurerm remote backend** stores state in an Azure Storage blob. Every runner reads and
writes the same file, and Terraform automatically acquires a blob lease (lock) so two runs
cannot corrupt the file simultaneously.

---

## Step 1 — Create the Terraform State Storage (One-Time, Manual)

Run these Azure CLI commands **once** from your local machine before the first `terraform init`.

```bash
# Variables — change the suffix if the storage account name is already taken
RG_NAME="rg-tfstate-ezfit"
SA_NAME="sttfstateezfit"     # must be globally unique, lowercase, 3-24 chars, alphanumeric
CONTAINER="tfstate"
LOCATION="eastus"

# 1. Create dedicated resource group for state (separate from app resources)
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION"

# 2. Create storage account (LRS is cheapest; state files are tiny)
az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false

# 3. Create the blob container
az storage container create \
  --name "$CONTAINER" \
  --account-name "$SA_NAME"
```

After running these commands, update `infra/terraform/backend.tf` if you used different names.

---

## Step 2 — Create Azure OIDC Credentials for GitHub Actions

GitHub Actions logs into Azure using **OIDC (Workload Identity Federation)** — no stored
client secret required. The token is issued by GitHub and verified directly by Azure AD.

### 2a. Register an App Registration

```bash
APP_NAME="sp-ezfit-github-actions"

APP_ID=$(az ad app create \
  --display-name "$APP_NAME" \
  --query appId \
  --output tsv)

echo "App (client) ID: $APP_ID"
```

### 2b. Create a Service Principal for the App

```bash
SP_OBJ_ID=$(az ad sp create \
  --id "$APP_ID" \
  --query id \
  --output tsv)

echo "Service Principal Object ID: $SP_OBJ_ID"
```

### 2c. Assign Contributor Role on the Subscription

```bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)

az role assignment create \
  --assignee "$APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### 2d. Add Federated Identity Credentials (OIDC Trust)

You need two federated credentials: one for PRs and one for pushes to main.

```bash
# For pull_request events
az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters '{
    "name": "github-pr",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:Azahar002/eZ-fit:pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# For push to main
az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:Azahar002/eZ-fit:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

Replace `Azahar002/eZ-fit` with your actual GitHub `owner/repo` if different.

---

## Step 3 — Add GitHub Repository Variables

In your GitHub repository go to **Settings → Secrets and variables → Actions → Variables**
and add these three **Variables** (not secrets — they are not sensitive):

| Variable name          | Where to get the value                          |
|------------------------|-------------------------------------------------|
| `AZURE_CLIENT_ID`      | `$APP_ID` from Step 2a above                    |
| `AZURE_TENANT_ID`      | `$TENANT_ID` from Step 2c above                 |
| `AZURE_SUBSCRIPTION_ID`| `$SUBSCRIPTION_ID` from Step 2c above           |

These are referenced in the workflow as `${{ vars.AZURE_CLIENT_ID }}` etc.

---

## How the PR Plan Works

When you open (or update) a pull request that touches any file under `infra/terraform/**`:

1. The `terraform.yml` workflow triggers on the `pull_request` event.
2. It runs `fmt check → init → validate → plan`.
3. The plan output is posted as a comment on the PR so reviewers can see exactly what
   Azure changes will be made before merging.
4. `terraform apply` does **not** run on PRs — only plan.

If the plan step fails, the workflow fails and the PR is blocked.

---

## How the Main Apply Works

When a PR is merged into `main` (and the merge touches `infra/terraform/**`):

1. The `terraform.yml` workflow triggers on the `push` to main event.
2. It runs `fmt check → init → validate → plan → apply`.
3. `terraform apply -auto-approve` uses the plan file generated in the same run, so
   the apply is deterministic — it applies exactly what was planned.

---

## Troubleshooting Common Errors

### `Error: Backend initialization required`

You have a `backend.tf` but have not run `terraform init` with the remote backend yet.
Run locally:

```bash
cd infra/terraform
terraform init
```

This creates or updates `.terraform/terraform.tfstate` (the backend pointer) which is
committed via `.terraform.lock.hcl`. Re-push and the CI init will work.

### `Error: Failed to get existing workspaces: ... 403`

The service principal does not have Storage Blob Data Contributor on the storage account.
Run:

```bash
az role assignment create \
  --assignee "$APP_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.Storage/storageAccounts/$SA_NAME"
```

### `Error acquiring the state lock`

A previous run crashed while holding the state lock. Force-unlock with:

```bash
cd infra/terraform
terraform force-unlock <LOCK_ID>
```

The lock ID is shown in the error message.

### `ClientAuthorizationFailed` / OIDC token rejected

- Check that the federated credential subject exactly matches the GitHub ref (`pull_request`
  vs `ref:refs/heads/main`).
- Confirm `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` are set as
  **Variables** (not Secrets) in GitHub repository settings.
- The workflow sets `ARM_USE_OIDC: "true"` — do not also set `ARM_CLIENT_SECRET`.

### `terraform fmt -check` fails

Run `terraform fmt -recursive` locally in `infra/terraform/`, commit the reformatted files,
and push again.
