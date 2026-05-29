# Stage 7: Terraform Automation with GitHub Actions — EZ-FIT

**Date:** 2026-05-29
**Branch:** feature/terraform-automation

---

## What Was Created

| File | Action | Purpose |
|------|--------|---------|
| `.github/workflows/terraform.yml` | Created | GitHub Actions workflow: plan on PR, apply on main merge |
| `infra/terraform/backend.tf` | Created | azurerm remote backend — moves state from local to Azure Storage |
| `docs/terraform-automation-setup.md` | Created | Manual Azure setup guide (state storage, OIDC, GitHub variables) |
| `.claude/plans/07-terraform-automation.md` | Created | This stage record |

---

## How the Workflow Behaves

### Trigger condition

The workflow only runs when files under `infra/terraform/**` change.
App code changes (Python, Docker) do not trigger it — that is handled by `ci.yml`.

### On pull request to main

Steps run in order:

1. `terraform fmt -check -recursive` — fails fast if any file has formatting issues
2. `terraform init` — downloads provider, connects to remote backend
3. `terraform validate` — checks syntax and provider schema
4. `terraform plan -out=tfplan` — shows what Azure changes will be made
5. Plan output is posted as a comment on the PR (via `actions/github-script`)
6. Apply does **not** run

### On push/merge to main

Same steps, then:

5. `terraform apply -auto-approve tfplan` — applies the plan generated in step 4

The `apply` step is gated with:
```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```
so it cannot accidentally run on forks or other branches.

### Authentication

Uses Azure OIDC (Workload Identity Federation) — no stored client secret.
GitHub issues a short-lived token; Azure AD verifies it directly.
Environment variables `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, and
`ARM_USE_OIDC=true` are set from GitHub repository Variables.

---

## What Manual Azure Setup Is Required Before Using This

The following must be done **once** before the workflow can run successfully.
See `docs/terraform-automation-setup.md` for exact commands.

### 1. Create Terraform state storage

```bash
az group create --name rg-tfstate-ezfit --location eastus
az storage account create --name sttfstateezfit --resource-group rg-tfstate-ezfit \
  --location eastus --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false
az storage container create --name tfstate --account-name sttfstateezfit
```

### 2. Create Azure App Registration and Service Principal with OIDC trust

```bash
APP_ID=$(az ad app create --display-name sp-ezfit-github-actions --query appId --output tsv)
az ad sp create --id "$APP_ID"
az role assignment create --assignee "$APP_ID" --role Contributor \
  --scope "/subscriptions/$(az account show --query id -o tsv)"
# Add two federated credentials: one for pull_request, one for refs/heads/main
```

### 3. Set GitHub repository Variables

| Name | Value |
|------|-------|
| `AZURE_CLIENT_ID` | App Registration client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

Go to: GitHub repo → Settings → Secrets and variables → Actions → Variables

### 4. Run terraform init locally (one time, after backend.tf is committed)

```bash
cd infra/terraform
terraform init
```

This migrates any existing local state to the remote backend and updates
`.terraform.lock.hcl`. Commit the updated lock file.

---

## Exact Commands to Test

### Validate workflow YAML syntax locally (requires actionlint)

```bash
brew install actionlint
actionlint .github/workflows/terraform.yml
```

### Verify fmt check passes locally

```bash
cd infra/terraform
terraform fmt -check -recursive
```

### Verify validate passes locally (requires init with backend)

```bash
cd infra/terraform
terraform init
terraform validate
```

### Simulate PR behavior (plan only, no apply)

```bash
cd infra/terraform
terraform plan -no-color
```

### Trigger the GitHub Actions workflow

1. Push the feature branch and open a PR to main.
2. Check the Actions tab — `Terraform Plan / Apply` job should appear.
3. After it completes, the plan output appears as a PR comment.
4. Merge the PR — a second run triggers and applies.

---

## What Remains for Stage 8

| # | Task |
|---|------|
| 1 | Build the real EZ-FIT Docker image in CI (`ci.yml`) |
| 2 | Push the image to ACR (`acrezfitdev.azurecr.io/ezfit:latest`) |
| 3 | Update `container_image` and `container_port` in `terraform.tfvars` |
| 4 | Re-run `terraform apply` (manually or via the automation) to deploy real app |
| 5 | Migrate ACR auth from admin credentials to managed identity |
| 6 | (Optional) Add health-check probe to the Container App definition |
