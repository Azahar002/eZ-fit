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
  admin_enabled       = true

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
# Managed Identity for Container App                                  #
# Allows the Container App to pull images from ACR without           #
# admin credentials or client secrets.                               #
# ------------------------------------------------------------------ #

resource "azurerm_user_assigned_identity" "container_app" {
  name                = "id-ezfit-ca-dev"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
}

# ------------------------------------------------------------------ #
# Container App                                                       #
# ------------------------------------------------------------------ #

resource "azurerm_container_app" "this" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.this.name
  revision_mode                = "Single"

  depends_on = [azurerm_role_assignment.acr_pull]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_app.id]
  }

  registry {
    server   = azurerm_container_registry.this.login_server
    identity = azurerm_user_assigned_identity.container_app.id
  }

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

  # The CD workflow updates the image via az containerapp update.
  # Ignoring image here prevents terraform apply from reverting it.
  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
    ]
  }

  tags = var.tags
}
