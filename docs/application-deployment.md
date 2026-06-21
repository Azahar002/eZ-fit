# Application Deployment — Stage 8

This document covers the automated deployment pipeline that builds, pushes, and deploys the eZ-fit Flask application to Azure Container Apps via GitHub Actions.

---

## Overview

```
push to main (app files)
       │
       ▼
 [test] pytest
       │ passes
       ▼
 [build-and-deploy]
  az acr build → ACR (ezfit-web:<sha>)
       │
       ▼
  az containerapp update
       │
       ▼
  /health check (10 retries × 15s)
```

The workflow lives at `.github/workflows/deploy-app.yml`.

---

## Triggers

| Trigger | Condition |
|---------|-----------|
| `push` to `main` | Only when `app.py`, `requirements.txt`, `Dockerfile`, `templates/**`, or `static/**` change |
| `workflow_dispatch` | Manual trigger from GitHub Actions UI |

Terraform-only changes (e.g. `infra/terraform/**`) do not trigger this workflow.

---

## Image Tagging

Images are tagged with the full Git commit SHA:

```
acrezfitdev.azurecr.io/ezfit-web:<github-sha>
```

- No `latest` tag is ever pushed.
- Every deployment is traceable to an exact commit.
- To find which image is running: `az containerapp show --name ca-ezfit-web-dev --resource-group rg-ezfit-dev-eastus --query properties.template.containers[0].image -o tsv`

---

## Authentication

| Step | Auth method |
|------|-------------|
| Azure login | GitHub OIDC — no stored secrets |
| ACR build (`az acr build`) | Inherits OIDC token via Azure CLI — no admin credentials |
| Container App pull | User-assigned managed identity (`id-ezfit-ca-dev`) with `AcrPull` role |

---

## Required GitHub Repository Variables

Add these in **Settings → Secrets and variables → Actions → Variables**:

| Variable | Value |
|----------|-------|
| `AZURE_CLIENT_ID` | App registration client ID (already set) |
| `AZURE_TENANT_ID` | Azure AD tenant ID (already set) |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID (already set) |
| `AZURE_RESOURCE_GROUP` | `rg-ezfit-dev-eastus` ← **add this** |
| `AZURE_CONTAINER_REGISTRY_NAME` | `acrezfitdev` ← **add this** |
| `AZURE_CONTAINER_APP_NAME` | `ca-ezfit-web-dev` ← **add this** |

---

## Sequencing: First Deployment

Stage 8 must be merged before the CD pipeline can succeed. The Terraform apply that follows merge creates the managed identity and grants it `AcrPull`. Only then can Container Apps pull from ACR using the identity.

1. Merge this PR (ensure `tfAction: apply` in `infrastructure/infrastructure.yml`).
2. Terraform apply runs automatically — creates `id-ezfit-ca-dev` and AcrPull role assignment.
3. Trigger `deploy-app.yml` via `workflow_dispatch` (or push an app file to main).
4. Verify the health check step passes in the Actions log.

---

## Terraform and CD Image Coexistence

The Container App's image in Terraform is managed via `lifecycle { ignore_changes = [template[0].container[0].image] }`. This means:

- Terraform apply **will not revert** the image after the CD workflow updates it.
- `var.container_image` (the placeholder) is only used for the very first `terraform apply` before any CD run.
- Subsequent Terraform applies update managed identity, ingress, CPU/memory, etc. — but leave the image alone.

---

## Manual Rollback

To redeploy a previous image (rollback to commit `<sha>`):

```bash
az containerapp update \
  --name ca-ezfit-web-dev \
  --resource-group rg-ezfit-dev-eastus \
  --image acrezfitdev.azurecr.io/ezfit-web:<sha>
```

---

## Health Check

The workflow polls `https://<app-fqdn>/health` with up to 10 attempts, 15 seconds apart (max 2.5 minutes). The endpoint must return HTTP 200 and `{"status": "healthy"}`.

The Flask implementation is in `app.py`:

```python
@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200
```

---

## One-Time Azure Role Assignment (if needed)

`az acr build` requires the GitHub Actions service principal to have `Contributor` on the resource group (standard from the Terraform OIDC setup) OR explicitly `AcrPush` on the ACR.

If `az acr build` fails with an authorization error:

```bash
az role assignment create \
  --assignee <AZURE_CLIENT_ID> \
  --role AcrPush \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-ezfit-dev-eastus/providers/Microsoft.ContainerRegistry/registries/acrezfitdev
```

The Container App managed identity's `AcrPull` role is granted automatically by Terraform — no manual command needed.

---

## Related Documentation

- [terraform-automation-setup.md](terraform-automation-setup.md) — OIDC setup, GitHub variables, state backend
- [terraform-action-control.md](terraform-action-control.md) — How `tfAction` controls apply/destroy
