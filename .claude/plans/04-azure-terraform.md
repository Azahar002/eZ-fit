# Plan 04: Azure Infrastructure with Terraform

## Goal
Provision all Azure resources needed to host EZ-FIT using Terraform. Keep costs minimal.

## Resources to Create
| Resource | SKU/Tier | Why |
|---|---|---|
| Resource Group | n/a | Container for all resources |
| Azure Container Registry | Basic | Cheapest; stores Docker images |
| Log Analytics Workspace | PerGB2018 | Required by Container Apps |
| Container Apps Environment | Consumption | Pay-per-use, scales to zero |
| Container App | n/a | Runs the EZ-FIT container |

## Steps

1. **Create terraform/ directory**
   ```
   terraform/
     main.tf       — provider, resource group
     acr.tf        — Azure Container Registry
     logs.tf       — Log Analytics Workspace
     container.tf  — Container Apps Environment + App
     variables.tf  — input variables
     outputs.tf    — ACR login server, app URL
   ```

2. **Configure provider**
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
     }
   }
   provider "azurerm" { features {} }
   ```

3. **Key variable defaults**
   - `location = "uksouth"` (or closest region)
   - `acr_sku = "Basic"`
   - `min_replicas = 0` (scales to zero when idle)
   - `max_replicas = 1` (cost cap)

4. **Container App ingress**
   - External ingress enabled
   - Port 5001
   - `allow_insecure_connections = false`

5. **Initialize and plan**
   ```bash
   cd terraform/
   terraform init
   terraform plan -out=tfplan
   # Review: should show ~5 resources to add
   terraform apply tfplan
   ```

6. **Capture outputs**
   After apply, note:
   - ACR login server (used in GitHub Actions)
   - Container App URL (the live website URL)

## Done When
- `terraform apply` succeeds with no errors
- Container App URL loads (will show error until image is pushed — that's OK)
- All resources tagged `project = "ezfit"`
