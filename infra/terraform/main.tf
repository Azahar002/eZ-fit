# ------------------------------------------------------------------ #
# Resource Group                                                      #
# ------------------------------------------------------------------ #

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------ #
# Azure Container Registry (Basic SKU — cheapest tier)               #
# ------------------------------------------------------------------ #

resource "azurerm_container_registry" "this" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"

  # Admin user enabled for initial simple push/pull workflow.
  # Migrate to managed identity or OIDC token in Stage 7 for production-grade auth.
  admin_enabled = true

  tags = var.tags
}

# ------------------------------------------------------------------ #
# Log Analytics Workspace                                             #
# Required by Azure Container Apps Environment for log ingestion     #
# ------------------------------------------------------------------ #

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# ------------------------------------------------------------------ #
# Container Apps Environment (consumption/serverless, no VNet)       #
# ------------------------------------------------------------------ #

resource "azurerm_container_app_environment" "this" {
  name                       = var.container_app_environment_name
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  tags                       = var.tags
}

# ------------------------------------------------------------------ #
# Container App                                                       #
# ------------------------------------------------------------------ #

resource "azurerm_container_app" "this" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.this.name
  revision_mode                = "Single"

  template {
    container {
      name   = "ezfit-web"
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory
    }
  }

  ingress {
    external_enabled = true
    target_port      = var.container_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags
}
