# EZ-FIT Terraform — Stage 6: Azure Infrastructure

## What This Creates

| Resource | Name (example) | Purpose |
|---|---|---|
| Resource Group | `rg-ezfit-dev-eastus` | Container for all EZ-FIT Azure resources |
| Azure Container Registry | `acrezfitdev.azurecr.io` | Private Docker image registry (Basic SKU) |
| Log Analytics Workspace | `law-ezfit-dev` | Log ingestion for Container Apps (required) |
| Container Apps Environment | `cae-ezfit-dev` | Serverless/consumption runtime environment |
| Container App | `ca-ezfit-web-dev` | Publicly accessible web app (HTTPS, port 5000) |

## What This Does NOT Create

This stage is intentionally minimal:

- No GitHub Actions Azure deployment (Stage 7)
- No Azure Front Door or WAF
- No database
- No Key Vault or Storage Account
- No Private Endpoints or VNet integration
- No AKS
- No custom domain
- No DNS records

## Prerequisites

1. **Azure CLI** — [Install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform >= 1.5.0** — [Install guide](https://developer.hashicorp.com/terraform/install)
3. **Azure subscription** with permission to create resources

## Setup

### 1. Log in to Azure

```bash
az login
```

Verify the correct subscription is active:

```bash
az account show
```

To switch subscriptions:

```bash
az account set --subscription "<subscription-id>"
```

### 2. Create your tfvars file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and review every value. Key things to check:

- `container_registry_name` must be globally unique across Azure (alphanumeric only). If `acrezfitdev` is taken, add a short suffix.
- `container_port = 80` is correct for the placeholder image. Change to `5000` in Stage 7 when deploying the real app.

## Commands

### Initialize Terraform (download Azure provider)

```bash
terraform init
```

### Format check

```bash
terraform fmt
```

### Validate configuration

```bash
terraform validate
```

> `terraform validate` requires `terraform init` to have been run first so the Azure provider plugin is present.

### Preview what will be created

```bash
terraform plan -var-file="terraform.tfvars"
```

### Apply (create resources)

```bash
terraform apply -var-file="terraform.tfvars"
```

Type `yes` when prompted.

## Expected Outputs After Apply

```
Outputs:

resource_group_name = "rg-ezfit-dev-eastus"
acr_login_server    = "acrezfitdev.azurecr.io"
container_app_name  = "ca-ezfit-web-dev"
container_app_url   = "https://ca-ezfit-web-dev.<unique-hash>.eastus.azurecontainerapps.io"
```

The `container_app_url` is the live public URL. Open it in a browser to verify the placeholder app is running.

To retrieve outputs at any time after apply:

```bash
terraform output
terraform output container_app_url
```

## Cleanup

To destroy all resources created by this Terraform:

```bash
terraform destroy -var-file="terraform.tfvars"
```

Type `yes` when prompted. This deletes everything in the resource group that Terraform manages.

## Notes on ACR Authentication

Admin user is enabled on the Container Registry for simplicity in Stage 7 (direct `docker push` using the registry username/password).

For production or CI/CD pipelines, migrate to **managed identity** or **OIDC federated credentials** (GitHub Actions workload identity). This avoids storing registry credentials as GitHub secrets.

---

> **Stage 6 only creates infrastructure.**
> GitHub Actions deployment to Azure, pushing Docker images to ACR, and wiring CI/CD will be added in Stage 7.
