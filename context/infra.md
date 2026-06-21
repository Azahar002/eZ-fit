# eZ-fit — Infrastructure Context

## Architecture Overview

```
GitHub (push / PR)
    │
    ├── .github/workflows/ci.yml
    │       pytest → Docker build (every push/PR)
    │
    └── .github/workflows/terraform.yml
            PR    → terraform fmt + validate + plan (plan posted as PR comment)
            Merge → terraform apply OR destroy (controlled by infrastructure.yml)
                            │
                            ▼
                    Azure Subscription
                    ├── rg-ezfit-dev-eastus  (app resources)
                    │   ├── Azure Container Registry (ACR)
                    │   ├── Log Analytics Workspace
                    │   ├── Container Apps Environment
                    │   └── Container App  ← runs the Flask app
                    │
                    └── rg-tfstate-ezfit  (state storage)
                        └── Storage Account: sttfstateezfit
                            └── Blob Container: tfstate
```

---

## Stack

| Layer | Technology |
|-------|-----------|
| Containerization | Docker (Python 3.12-slim + Gunicorn) |
| Cloud | Azure |
| Compute | Azure Container Apps (serverless, consumption pricing) |
| Registry | Azure Container Registry (Basic SKU) |
| Observability | Azure Log Analytics (30-day retention) |
| IaC | Terraform 1.9.0, Azure provider ~4.0 |
| State backend | Azure Storage (remote, already configured) |
| CI/CD | GitHub Actions |
| Auth to Azure | OIDC Workload Identity (no client secrets stored) |

---

## File Map

```
Dockerfile                          Container build definition

infra/terraform/
  main.tf                           All Azure resource definitions
  variables.tf                      Input variables (region, image, CPU, memory)
  providers.tf                      Azure provider + OIDC config
  outputs.tf                        Outputs: ACR login server, Container App URL
  backend.tf                        Remote state pointer (Azure Storage)
  terraform.tfvars                  Sensitive values — gitignored

.github/workflows/
  ci.yml                            pytest + Docker build on push/PR
  terraform.yml                     Terraform plan/apply/destroy automation

infrastructure/
  infrastructure.yml                Control file — sets tfAction per environment
```

---

## Azure Resources

| Resource | Name | Notes |
|----------|------|-------|
| Resource Group (app) | `rg-ezfit-dev-eastus` | All app resources |
| Resource Group (state) | `rg-tfstate-ezfit` | Terraform remote state only |
| Container Registry | ACR (Basic SKU) | ~$5/month |
| Log Analytics | — | 30-day retention |
| Container Apps Environment | — | Serverless, consumption pricing |
| Container App | — | Runs Flask on port 5000 |
| Storage Account | `sttfstateezfit` | Terraform state backend |

---

## CI/CD Workflows

### `ci.yml` — Runs on every push and PR
1. Checkout code
2. Set up Python 3.12
3. `pip install -r requirements.txt`
4. `pytest` (8 tests)
5. `docker build -t ezfit-ci .`

### `terraform.yml` — Runs on changes to `infra/terraform/**` or `infrastructure/infrastructure.yml`

**On PR:**
1. `terraform fmt -check`
2. `terraform init`
3. `terraform validate`
4. `terraform plan` → plan output posted as PR comment

**On merge to `main`:**
- If `tfAction: apply` → `terraform apply -auto-approve`
- If `tfAction: destroy` → `terraform destroy -auto-approve` (requires manual approval via GitHub environment `ezfit-destroy`)

### Controlling apply vs destroy

Edit `infrastructure/infrastructure.yml`:
```yaml
infrastructure:
  dev:
    ezfit:
      enabled: true
      tfAction: apply     # change to 'destroy' to tear down
      terraformDirectory: infra/terraform
      environment: dev
```

---

## Current State

### What Is Complete ✅
- Dockerfile builds and runs correctly
- All Azure resources provisioned and working
- Remote Terraform state configured in Azure Storage (no local state needed)
- GitHub Actions CI: pytest + Docker build passing
- GitHub Actions Terraform: plan on PR, apply/destroy on merge
- OIDC auth to Azure (no secrets in GitHub)
- `docs/terraform-automation-setup.md` and `docs/terraform-action-control.md` written

### What Is Pending ❌

- [ ] **Container image auto-deploy** — CI builds the Docker image but does not push it to ACR or trigger a Container App revision. CD (push + deploy) not yet wired up.
- [ ] **`terraform.tfstate` in git** — local state file is committed. It is redundant (remote state is configured) and exposes infra details. Add to `.gitignore`.
- [ ] **Health check in Container Apps** — verify the `/health` route is configured as the liveness probe in `main.tf`
- [ ] **Custom domain / HTTPS** — Container App currently uses the default Azure-generated URL. No custom domain configured.
- [ ] **Secrets management** — no Azure Key Vault or GitHub secrets strategy documented for app-level secrets (DB path, secret key, etc.)
- [ ] **`.env.example`** — no documented list of environment variables the app needs at runtime

---

## 🚨 Active Warning

**`infrastructure/infrastructure.yml` is currently set to `tfAction: destroy`.**

Any merge to `main` that touches `infra/terraform/**` or `infrastructure/infrastructure.yml` will trigger a full `terraform destroy`, deleting all Azure resources.

**Before merging any infra changes:** set `tfAction: apply` in `infrastructure/infrastructure.yml`.

---

## Pending To-Do List

### High Priority
1. Change `tfAction` from `destroy` → `apply` in `infrastructure/infrastructure.yml`
2. Add `terraform.tfstate` and `terraform.tfstate.backup` to `.gitignore`
3. Wire up CD: after Docker build in `ci.yml`, push image to ACR and update Container App revision
4. Confirm `/health` is set as liveness probe in `main.tf` Container App config

### Medium Priority
5. Add `.env.example` listing required runtime environment variables
6. Document secrets strategy (how app secrets get into Container App env vars)
7. Configure custom domain + managed certificate in Terraform

### Low Priority
8. Add non-root user to Dockerfile (`USER appuser`)
9. Add resource tags to all Terraform resources (project, environment, owner)
10. Set up Azure Monitor alerts (CPU, memory, request errors)

---

## Useful Commands

```bash
# Local Docker build + run
docker build -t ezfit .
docker run -p 5000:5000 ezfit

# Terraform (from infra/terraform/)
terraform init
terraform plan
terraform apply
terraform destroy

# Check what's deployed
terraform output
```
