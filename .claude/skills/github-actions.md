# Skill: GitHub Actions (EZ-FIT context)

## Workflow File Location
`.github/workflows/deploy.yml`

## Trigger
```yaml
on:
  push:
    branches: [main]
```
Only deploy from `main`. Feature branches never trigger a deploy.

## Required Secrets
Set in GitHub repo → Settings → Secrets and variables → Actions:

| Secret Name | How to Get |
|---|---|
| `AZURE_CREDENTIALS` | `az ad sp create-for-rbac --name ezfit-sp --role contributor --scopes /subscriptions/<id>/resourceGroups/ezfit-rg --sdk-auth` |
| `ACR_LOGIN_SERVER` | Terraform output: `acr_login_server` |
| `ACR_USERNAME` | ACR → Access keys → Username |
| `ACR_PASSWORD` | ACR → Access keys → password |
| `FLASK_SECRET_KEY` | Generate: `python -c "import secrets; print(secrets.token_hex(32))"` |

## Key Actions Used
```yaml
- uses: actions/checkout@v4
- uses: docker/login-action@v3
- uses: docker/build-push-action@v5
- uses: azure/login@v1
- uses: azure/container-apps-deploy-action@v1
```

## Image Tagging
Always use `${{ github.run_number }}` or `${{ github.sha }}` — never `latest`.
This makes every deploy traceable and rollback possible.

## Debugging Failed Runs
- Check Actions tab in GitHub for logs
- Re-run failed jobs from the UI
- For ACR push failures: check `ACR_LOGIN_SERVER` matches exactly
- For Container App deploy failures: check `containerAppName` and `resourceGroup` match Terraform names

## Gotchas
- The `azure/container-apps-deploy-action` requires the image to already be in ACR before the deploy step
- Secrets are masked in logs — if a value is empty, the step will silently fail; verify secret names match exactly
