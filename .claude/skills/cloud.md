# Skill: Azure Cloud (EZ-FIT context)

## Key Concepts for This Project

### Resource Group
All EZ-FIT resources live in one resource group: `ezfit-rg`.
Deleting the resource group deletes everything — useful for teardown.

### Azure Container Registry (ACR)
- Stores Docker images privately
- Basic SKU is cheapest (~$5/month)
- Admin access enabled for simple CI/CD (service principal preferred for real teams)
- Login server format: `<name>.azurecr.io`

### Log Analytics Workspace
- Required by Container Apps Environment
- Collects container logs
- Query logs in Azure Portal → Log Analytics → `ContainerAppConsoleLogs_CL`

### Container Apps Environment
- The hosting layer for Container Apps
- Consumption plan = pay per request, scales to zero
- Linked to Log Analytics workspace

### Container App
- Runs the EZ-FIT Docker container
- External ingress on port 5001
- Environment variables injected here (not in Docker image)
- Scaling: `min_replicas = 0`, `max_replicas = 1` (cost cap for portfolio)

## Useful Azure CLI Commands
```bash
az login
az account show
az group list --output table
az acr list --output table
az containerapp show -n ezfit-app -g ezfit-rg --query "properties.configuration.ingress.fqdn"
```

## Cost Estimate (approx)
- ACR Basic: ~$5/month
- Container App (low traffic): ~$0–2/month (scales to zero)
- Log Analytics: ~$0 (under free tier for small logs)
- **Total: ~$5–7/month**
