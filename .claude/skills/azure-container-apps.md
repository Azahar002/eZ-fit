# Skill: Azure Container Apps (EZ-FIT context)

## What It Is
A serverless container hosting service. No VMs, no Kubernetes to manage.
EZ-FIT uses the Consumption plan — pay only when requests come in, scales to zero.

## Key Configuration for EZ-FIT

### Ingress (public access)
```hcl
ingress {
  external_enabled = true
  target_port      = 5001
  transport        = "http"
  allow_insecure_connections = false
}
```

### Scaling (cost control)
```hcl
min_replicas = 0   # scales to zero when idle — no cost
max_replicas = 1   # cap at 1 replica for portfolio
```

### Environment Variables (injected at runtime, not baked into image)
```hcl
env {
  name  = "FLASK_SECRET_KEY"
  value = var.flask_secret_key  # passed via Terraform variable or set in portal
}
env {
  name  = "FLASK_DEBUG"
  value = "false"
}
env {
  name  = "FLASK_PORT"
  value = "5001"
}
```

## First Cold Start
Scaling to zero means the first request after idle takes ~5–10 seconds. Acceptable for a portfolio site.

## Viewing Logs
In Azure Portal:
1. Go to Container App → Logs
2. Or use Log Analytics:
```kusto
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "ezfit-app"
| order by TimeGenerated desc
| take 50
```

## Updating the App
Deploying a new image tag via GitHub Actions creates a new revision automatically.
Old revisions are kept (useful for rollback).

## Getting the App URL
```bash
az containerapp show \
  -n ezfit-app \
  -g ezfit-rg \
  --query "properties.configuration.ingress.fqdn" \
  -o tsv
```
Format: `ezfit-app.<hash>.<region>.azurecontainerapps.io`

## Gotchas
- Container App must have the Log Analytics workspace linked — required at environment creation, cannot be changed later
- If min_replicas = 0, health checks won't work on a sleeping instance — that's expected
- ACR image must be accessible to the Container App (enable admin access on ACR or use managed identity)
