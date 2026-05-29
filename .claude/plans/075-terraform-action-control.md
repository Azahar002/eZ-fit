# Stage 7.5 — Terraform Action Control

## What Was Changed

| File | Action |
|---|---|
| `infrastructure/infrastructure.yml` | Created — control file for tfAction |
| `.github/workflows/terraform.yml` | Updated — 4-job workflow with action-based branching |
| `docs/terraform-action-control.md` | Created — user documentation |
| `.claude/plans/075-terraform-action-control.md` | Created — this file |

---

## Why `infrastructure.yml` Was Added

Before this stage, `terraform destroy` could only be run manually from a laptop. There was no audit trail, no PR review, and no protection gate.

`infrastructure/infrastructure.yml` follows the enterprise infrastructure-as-code pattern of a separate control file that declares intent. Changing `tfAction` produces a PR diff, which means every destroy is:
- Reviewed before merging
- Blocked behind a GitHub environment approval gate
- Visible in git history

---

## How Apply/Destroy Are Controlled

The workflow reads `tfAction` from `infrastructure/infrastructure.yml` in a `read-config` job at the start of every run. Downstream jobs branch based on this value:

```
read-config
    └── terraform-plan (all events)
            ├── terraform-apply  (push+main, tfAction=apply)
            └── terraform-destroy (push+main, tfAction=destroy, requires ezfit-destroy env approval)
```

- `tfAction: plan` → plan only, no resource changes on merge
- `tfAction: apply` → apply runs automatically on merge
- `tfAction: destroy` → destroy runs after manual approval in GitHub environment `ezfit-destroy`

---

## Exact Test Steps

### 1. Validate YAML locally
```bash
python3 -c "import yaml; print(yaml.safe_load(open('infrastructure/infrastructure.yml')))"
```

### 2. Test PR plan (apply action)
- Ensure `tfAction: apply` in `infrastructure/infrastructure.yml`
- Open a PR with any change to `infra/terraform/**` or `infrastructure/infrastructure.yml`
- Expected GitHub Actions jobs: `read-config` ✅, `terraform-plan` ✅, `terraform-apply` ⏭ skipped, `terraform-destroy` ⏭ skipped
- Expected PR comment: plan output with `#### Terraform Plan 📖` header

### 3. Test merge to main (apply action)
- Merge the PR
- Expected: `terraform-apply` job runs, `terraform-destroy` skipped
- Verify: `az resource list --resource-group rg-ezfit-dev-eastus -o table`

### 4. Test PR plan (destroy action)
- Change `tfAction: destroy` in `infrastructure/infrastructure.yml`
- Open a PR
- Expected PR comment: plan output with `#### Terraform Plan (DESTROY) ⚠️` header

### 5. Test destroy gate
- Merge the destroy PR
- Expected: `terraform-destroy` job appears, **paused** at `ezfit-destroy` environment
- Go to GitHub Actions → Review deployments → Approve
- Expected: `terraform destroy` runs
- Verify: `az group exists --name rg-ezfit-dev-eastus` returns `false`

### 6. Test invalid tfAction
- Temporarily set `tfAction: invalid` in `infrastructure/infrastructure.yml`
- Open a PR
- Expected: `read-config` job fails with `ERROR: tfAction 'invalid' is not valid`

---

## What Remains for Stage 8

- Build the eZ-FIT Flask Docker image in CI
- Push image to Azure Container Registry (`acrezfitdev`)
- Update `terraform.tfvars` to use the real ACR image instead of the placeholder
- Update Container App to pull the new image on each push
- Wire `ci.yml` Docker steps into the Container App deployment flow
