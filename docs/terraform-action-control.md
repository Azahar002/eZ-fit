# Terraform Action Control

## Purpose of `infrastructure/infrastructure.yml`

`infrastructure/infrastructure.yml` is a source-of-truth control file that tells the GitHub Actions Terraform workflow what action to perform. Changing `tfAction` in this file is the only thing needed to switch between deploying infrastructure (`apply`) and tearing it down (`destroy`).

This eliminates the need to run `terraform destroy` manually from a laptop and provides an auditable, PR-reviewed record of every infrastructure lifecycle change.

---

## Allowed `tfAction` Values

| Value | PR Behaviour | Merge to Main Behaviour |
|---|---|---|
| `apply` | `terraform plan` | `terraform apply -auto-approve` |
| `plan` | `terraform plan` | `terraform plan` only — no changes made |
| `destroy` | `terraform plan -destroy` | `terraform destroy -auto-approve` (after manual approval) |

Invalid values cause the workflow to fail immediately with a clear error message.

---

## How PR Plan Works

On any pull request targeting `main` that changes `infra/terraform/**` or `infrastructure/infrastructure.yml`:

1. `read-config` job parses `infrastructure/infrastructure.yml` and outputs `tfAction`.
2. `terraform-plan` job runs `fmt`, `init`, `validate`, then:
   - If `tfAction` is `apply` or `plan` → `terraform plan -no-color`
   - If `tfAction` is `destroy` → `terraform plan -destroy -no-color`
3. Plan output is posted as a PR comment.
4. `terraform-apply` and `terraform-destroy` jobs are **skipped** on pull requests.

---

## How Merge to Main (Apply) Works

When `tfAction: apply` and a commit is pushed/merged to `main`:

1. `read-config` → `terraform-plan` → `terraform-apply` runs in sequence.
2. `terraform-apply` job: OIDC login → `terraform init` → `terraform apply -auto-approve`.
3. `terraform-destroy` job is skipped.

---

## How Merge to Main (Destroy) Works

When `tfAction: destroy` and a commit is pushed/merged to `main`:

1. `read-config` → `terraform-plan` → `terraform-destroy` runs in sequence.
2. `terraform-destroy` job uses GitHub environment `ezfit-destroy`.
3. **The job pauses and waits for manual approval** before running `terraform destroy -auto-approve`.
4. `terraform-apply` job is skipped.

---

## How to Create the `ezfit-destroy` GitHub Environment

1. Go to your repository on GitHub.
2. Click **Settings** → **Environments** → **New environment**.
3. Name it exactly: `ezfit-destroy`
4. Under **Deployment protection rules**, enable **Required reviewers**.
5. Add yourself (or a teammate) as a required reviewer.
6. Click **Save protection rules**.

Once configured, any destroy triggered by a merge to main will pause and send a notification to reviewers before proceeding.

---

## Safety Warning

> **Destroy is irreversible.** Running `terraform destroy` deletes all managed Azure resources including the Container Registry, Container App, Log Analytics Workspace, and Resource Group. Remote state in the backend storage account is not deleted by Terraform destroy, but the application infrastructure will be gone. Always review the destroy plan comment on the PR before approving the `ezfit-destroy` environment gate.

---

## Example: Apply Change

```yaml
# infrastructure/infrastructure.yml
infrastructure:
  dev:
    ezfit:
      tfAction: apply   # <-- deploy or update resources
```

Steps:
1. Set `tfAction: apply` (or keep it as default).
2. Commit the file along with any Terraform changes.
3. Open a PR → review the plan comment.
4. Merge to main → `terraform apply` runs automatically.
5. Verify:
   ```bash
   az resource list --resource-group rg-ezfit-dev-eastus -o table
   ```

---

## Example: Destroy Change

```yaml
# infrastructure/infrastructure.yml
infrastructure:
  dev:
    ezfit:
      tfAction: destroy   # <-- tear down all resources
```

Steps:
1. Set `tfAction: destroy`.
2. Commit and open a PR → review the **destroy plan** comment (marked with ⚠️).
3. Merge to main → `terraform-destroy` job appears in GitHub Actions, **paused** at `ezfit-destroy` environment gate.
4. Go to GitHub Actions → click **Review deployments** → **Approve**.
5. `terraform destroy -auto-approve` runs.
6. After it completes, set `tfAction` back to `apply` and open another PR to redeploy when ready.

---

## How to Verify Resources After Apply/Destroy

**After apply — resources should exist:**
```bash
az resource list --resource-group rg-ezfit-dev-eastus -o table
```

**After destroy — resource group should be gone:**
```bash
az group exists --name rg-ezfit-dev-eastus
# Returns: false
```

**Check Container App URL (after apply):**
```bash
az containerapp show \
  --name ca-ezfit-web-dev \
  --resource-group rg-ezfit-dev-eastus \
  --query properties.configuration.ingress.fqdn \
  -o tsv
```
