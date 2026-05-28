# Skill: Terraform (EZ-FIT context)

## Provider Setup
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # Remote state (recommended — add after first apply)
  # backend "azurerm" {
  #   resource_group_name  = "ezfit-rg"
  #   storage_account_name = "ezfittfstate"
  #   container_name       = "tfstate"
  #   key                  = "ezfit.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}
```

## Standard Resource Naming
- Resource group: `ezfit-rg`
- ACR: `ezfitacr` (globally unique, no hyphens)
- Log Analytics: `ezfit-logs`
- Container App Environment: `ezfit-env`
- Container App: `ezfit-app`

## File Structure
```
terraform/
  main.tf        — provider, resource group
  acr.tf         — Azure Container Registry
  logs.tf        — Log Analytics Workspace
  container.tf   — Container Apps Environment + App
  variables.tf   — input variables with defaults
  outputs.tf     — ACR login server URL, app FQDN
```

## Key Commands
```bash
terraform init          # download providers
terraform fmt           # format all .tf files
terraform validate      # syntax check
terraform plan          # preview changes
terraform apply         # create/update resources
terraform destroy       # tear everything down
```

## Gotchas
- ACR name must be globally unique and alphanumeric only (no hyphens)
- Container App needs Log Analytics workspace ID + key — pass via `azurerm_log_analytics_workspace` data source
- `min_replicas = 0` is essential for cost savings — container scales to zero when idle
- Credentials for ACR must be passed as secrets, not in `.tf` files
