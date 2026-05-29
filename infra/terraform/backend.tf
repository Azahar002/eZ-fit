terraform {
  backend "azurerm" {
    # The resource group, storage account, and container below must be created
    # manually before running terraform init.
    # See docs/terraform-automation-setup.md for the exact Azure CLI commands.
    resource_group_name  = "rg-tfstate-ezfit"
    storage_account_name = "sttfstateezfit"
    container_name       = "tfstate"
    key                  = "ezfit-dev.terraform.tfstate"
  }
}
