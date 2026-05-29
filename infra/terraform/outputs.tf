output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = azurerm_resource_group.this.name
}

output "acr_login_server" {
  description = "Login server URL for Azure Container Registry (e.g. acrezfitdev.azurecr.io)"
  value       = azurerm_container_registry.this.login_server
}

output "container_app_name" {
  description = "Name of the deployed Azure Container App"
  value       = azurerm_container_app.this.name
}

output "container_app_url" {
  description = "Public HTTPS URL of the Container App (available after apply)"
  value       = "https://${azurerm_container_app.this.latest_revision_fqdn}"
}
