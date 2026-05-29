variable "project_name" {
  description = "Short name for the project, used in resource naming"
  type        = string
  default     = "ezfit"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-ezfit-dev-eastus"
}

variable "container_registry_name" {
  description = "Globally unique name for Azure Container Registry (alphanumeric only, 5-50 chars)"
  type        = string
  default     = "acrezfitdev"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "law-ezfit-dev"
}

variable "container_app_environment_name" {
  description = "Name of the Azure Container Apps Environment"
  type        = string
  default     = "cae-ezfit-dev"
}

variable "container_app_name" {
  description = "Name of the Azure Container App"
  type        = string
  default     = "ca-ezfit-web-dev"
}

variable "container_image" {
  description = "Container image to deploy. Use placeholder for initial infra creation; replace with ACR image in Stage 7"
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_port" {
  description = "Port the container listens on. Use 80 with the placeholder image; use 5000 for the real Flask/Gunicorn app"
  type        = number
  default     = 5000
}

variable "cpu" {
  description = "CPU allocation per container replica (minimum 0.25 for consumption tier)"
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocation per container replica. Must pair correctly with cpu (0.25 cpu → 0.5Gi)"
  type        = string
  default     = "0.5Gi"
}

variable "log_retention_days" {
  description = "Log Analytics Workspace data retention in days (30 is the minimum/cheapest)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    project     = "ezfit"
    environment = "dev"
    managed_by  = "terraform"
  }
}
