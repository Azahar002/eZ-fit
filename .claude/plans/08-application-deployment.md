# Stage 8: Application Deployment Pipeline

## Goal

Deploy the real Flask app to Azure Container Apps through GitHub Actions using commit-SHA image tagging, OIDC auth, and managed identity ACR pull — no admin credentials or client secrets.

## Files Changed

| File | Change |
|------|--------|
| `infra/terraform/main.tf` | Add managed identity, AcrPull role assignment, update Container App with identity/registry blocks and lifecycle.ignore_changes |
| `.github/workflows/deploy-app.yml` | New CD workflow: pytest → az acr build → az containerapp update → health check |
| `docs/application-deployment.md` | Full deployment reference documentation |
| `.claude/plans/08-application-deployment.md` | This file |

## Terraform Additions (main.tf)

### New resources
- `azurerm_user_assigned_identity.container_app` — `id-ezfit-ca-dev` in the app resource group
- `azurerm_role_assignment.acr_pull` — grants the identity `AcrPull` on `azurerm_container_registry.this`

### Updated Container App
- `identity` block — attaches the user-assigned identity
- `registry` block — configures ACR pull via managed identity (no admin credentials)
- `lifecycle.ignore_changes = [template[0].container[0].image]` — prevents Terraform from reverting the image updated by the CD workflow

## Workflow Design (deploy-app.yml)

**Triggers:** `push` to `main` on app file paths + `workflow_dispatch`

**Jobs:**
1. `test` — pytest (always runs)
2. `build-and-deploy` — only on push/dispatch, runs after test passes
   - OIDC login via `azure/login@v2`
   - `az acr build` — builds in ACR cloud, uses Contributor role (no docker daemon, no credentials)
   - `az containerapp update` — updates image to `<acr-server>/ezfit-web:<sha>`
   - Health check loop — polls `/health` up to 10× with 15s gaps

## GitHub Variables Required

| Variable | Value | Status |
|----------|-------|--------|
| `AZURE_CLIENT_ID` | App registration client ID | Already set |
| `AZURE_TENANT_ID` | Azure AD tenant ID | Already set |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | Already set |
| `AZURE_RESOURCE_GROUP` | `rg-ezfit-dev-eastus` | **Add** |
| `AZURE_CONTAINER_REGISTRY_NAME` | `acrezfitdev` | **Add** |
| `AZURE_CONTAINER_APP_NAME` | `ca-ezfit-web-dev` | **Add** |

## Merge Sequence

1. Set `tfAction: apply` in `infrastructure/infrastructure.yml`
2. Merge PR → Terraform apply creates managed identity + AcrPull role
3. Trigger `deploy-app.yml` via `workflow_dispatch` or push an app file
4. Confirm health check passes

## Key Constraints

- No `latest` tag — every image tagged with full commit SHA
- No ACR admin credentials — `az acr build` uses OIDC/Contributor
- No new Azure resources beyond the managed identity (no Key Vault, no additional RGs)
- Terraform cannot revert CD-deployed images (lifecycle.ignore_changes)
