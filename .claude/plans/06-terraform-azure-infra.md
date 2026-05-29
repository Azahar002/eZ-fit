# Stage 6: Terraform Azure Infrastructure — EZ-FIT

**Date:** 2026-05-28
**Branch:** feature/terraform-azure-infra

---

## What Was Done

Created Terraform infrastructure-as-code under `infra/terraform/` to provision the minimum Azure resources needed to run the EZ-FIT portfolio site as a container on Azure Container Apps.

---

## Files Created or Changed

| File | Action | What It Does |
|------|--------|-------------|
| `infra/terraform/providers.tf` | Created | Pins Terraform >= 1.5.0, azurerm ~> 4.0 |
| `infra/terraform/variables.tf` | Created | All 15 input variables with defaults |
| `infra/terraform/main.tf` | Created | 5 Azure resources (see below) |
| `infra/terraform/outputs.tf` | Created | 4 outputs (RG name, ACR URL, app name, app URL) |
| `infra/terraform/terraform.tfvars.example` | Created | Safe-to-commit example values |
| `infra/terraform/README.md` | Created | Full usage documentation |
| `.gitignore` | Updated | Added Terraform state, lock file, and tfvars entries |

---

## Azure Resources Created by Terraform

| Resource | Terraform Resource | Example Name | Cost Notes |
|---|---|---|---|
| Resource Group | `azurerm_resource_group` | `rg-ezfit-dev-eastus` | Free |
| Container Registry | `azurerm_container_registry` | `acrezfitdev.azurecr.io` | ~$5/month (Basic SKU) |
| Log Analytics Workspace | `azurerm_log_analytics_workspace` | `law-ezfit-dev` | ~$0–$2/month at low volume |
| Container Apps Environment | `azurerm_container_app_environment` | `cae-ezfit-dev` | Free (consumption plan) |
| Container App | `azurerm_container_app` | `ca-ezfit-web-dev` | ~$0 at low traffic (per-request billing) |

**Estimated monthly cost: ~$5–$8 for a low-traffic portfolio site.**

---

## Why This Is the Cheapest Practical Azure Setup

- **Basic ACR SKU** — only tier that supports container push/pull. Geo-replication and private endpoints excluded.
- **Consumption Container Apps** — serverless; you pay per request and CPU second, not for idle time. A low-traffic portfolio site costs near $0 in compute.
- **No VNet** — VNet-injected environments add a fixed ~$130+/month charge for the dedicated infrastructure subnet. Excluded entirely.
- **30-day log retention** — minimum allowed; reduces Log Analytics storage cost.
- **0.25 vCPU / 0.5Gi** — smallest valid container size for the consumption tier.
- No Front Door, WAF, AKS, Key Vault, Storage, or database — all excluded.

---

## Placeholder Image

The default `container_image` in `terraform.tfvars.example` is:

```
mcr.microsoft.com/azuredocs/containerapps-helloworld:latest
```

This is a public Microsoft sample image used to validate the infrastructure without pushing a real image. It serves on port 80, so `container_port = 80` is set in the example tfvars for this phase.

In Stage 7, both values will be replaced:
- `container_image` → `acrezfitdev.azurecr.io/ezfit:latest`
- `container_port` → `5000`

---

## Exact Commands to Run Locally

### 1. Move into the Terraform directory

```bash
cd infra/terraform
```

### 2. Copy the example tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` if needed (especially `container_registry_name` — must be globally unique).

### 3. Log in to Azure

```bash
az login
az account show   # confirm correct subscription
```

### 4. Initialize Terraform (downloads Azure provider)

```bash
terraform init
```

### 5. Format check

```bash
terraform fmt
```

### 6. Validate configuration

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### 7. Preview changes

```bash
terraform plan -var-file="terraform.tfvars"
```

### 8. Apply

```bash
terraform apply -var-file="terraform.tfvars"
```

Type `yes` when prompted.

### 9. Destroy when done testing

```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## Expected Terraform Outputs After Apply

```
Outputs:

resource_group_name = "rg-ezfit-dev-eastus"
acr_login_server    = "acrezfitdev.azurecr.io"
container_app_name  = "ca-ezfit-web-dev"
container_app_url   = "https://ca-ezfit-web-dev.<unique>.eastus.azurecontainerapps.io"
```

Retrieve outputs at any time:

```bash
terraform output
terraform output container_app_url
```

---

## Terraform fmt / validate Results (Stage 6)

- `terraform fmt -check` — exit 0, no formatting changes needed
- `terraform validate` — requires `terraform init` first (Azure provider not yet downloaded locally)

To fully validate:

```bash
terraform init
terraform validate
```

---

## What Remains for Stage 7

| # | Task |
|---|------|
| 1 | Build and tag the EZ-FIT Docker image locally |
| 2 | Log in to ACR (`az acr login --name acrezfitdev`) |
| 3 | Push image to ACR (`docker push acrezfitdev.azurecr.io/ezfit:latest`) |
| 4 | Update `terraform.tfvars`: set real image path and `container_port = 5000` |
| 5 | Run `terraform apply` to redeploy Container App with real image |
| 6 | Add GitHub Actions workflow for automated build → push → deploy |
| 7 | (Optional) Migrate ACR auth from admin user to managed identity/OIDC |
