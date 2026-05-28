# Plan 05: GitHub Actions CI/CD

## Goal
Automate build → push → deploy on every push to `main`. Zero manual steps after merge.

## Pipeline Flow
```
push to main
  → build Docker image
  → push to Azure Container Registry
  → deploy to Azure Container App
  → verify URL is live
```

## Steps

1. **Create workflow file**
   Path: `.github/workflows/deploy.yml`

2. **Required GitHub Secrets**
   Set these in GitHub repo → Settings → Secrets:
   | Secret | Value |
   |---|---|
   | `AZURE_CREDENTIALS` | JSON from `az ad sp create-for-rbac` |
   | `ACR_LOGIN_SERVER` | e.g. `ezfitacr.azurecr.io` |
   | `ACR_USERNAME` | ACR admin username |
   | `ACR_PASSWORD` | ACR admin password |
   | `FLASK_SECRET_KEY` | Production secret key |

3. **Workflow structure**
   ```yaml
   on:
     push:
       branches: [main]

   jobs:
     build-and-deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: docker/login-action@v3
           with:
             registry: ${{ secrets.ACR_LOGIN_SERVER }}
             username: ${{ secrets.ACR_USERNAME }}
             password: ${{ secrets.ACR_PASSWORD }}
         - uses: docker/build-push-action@v5
           with:
             push: true
             tags: ${{ secrets.ACR_LOGIN_SERVER }}/ezfit:${{ github.run_number }}
         - uses: azure/login@v1
           with:
             creds: ${{ secrets.AZURE_CREDENTIALS }}
         - uses: azure/container-apps-deploy-action@v1
           with:
             containerAppName: ezfit-app
             resourceGroup: ezfit-rg
             imageToDeploy: ${{ secrets.ACR_LOGIN_SERVER }}/ezfit:${{ github.run_number }}
   ```

4. **Run DevOps review**
   Use command: `deploy-review` (Actions YAML section)

5. **Trigger first deploy**
   Push a small change to `main` and watch the Actions run.

## Done When
- Actions workflow completes green
- Container App URL serves the EZ-FIT landing page
- Image in ACR is tagged with run number (not `latest`)
