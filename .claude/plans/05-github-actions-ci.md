# Stage 5: GitHub Actions CI

**Status:** Completed (2026-05-28)

---

## What workflow was added

Created `.github/workflows/ci.yml` — a single-job GitHub Actions workflow named **CI**.

```yaml
name: CI

on:
  push:
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - run: pytest
      - run: docker build -t ezfit-ci .
```

---

## What checks run in CI

| Step | What it does |
|------|-------------|
| Checkout | Pulls the full repository onto the runner |
| Set up Python 3.12 | Matches the Python version used in the Dockerfile |
| Install dependencies | Installs Flask, pytest, gunicorn, pytest-flask from requirements.txt |
| Run pytest | Runs all 7 route tests; fails the workflow if any test fails |
| Build Docker image | Runs `docker build -t ezfit-ci .`; fails if the Dockerfile or app is broken |

---

## Why CI is needed before Azure deployment

- Azure deployment will push a Docker image to a registry and deploy it to Container Apps.
- If pytest or the Docker build is broken at push time, a broken image would be deployed.
- CI acts as a gate: nothing broken reaches the registry or the cloud.
- It also validates that the app still works after every change, not just before a manual deploy.

---

## When the workflow runs

- On every `push` to any branch
- On every `pull_request` to any branch

This means both day-to-day development pushes and PRs are validated automatically.

---

## Expected result

When the workflow runs on GitHub Actions:

```
✓ Checkout repository
✓ Set up Python 3.12
✓ Install dependencies
✓ Run pytest          — 7 passed
✓ Build Docker image  — Successfully built ezfit-ci
```

All steps green = workflow passes.

---

## Local verification (confirmed passing)

```bash
# pytest
source ezfit/bin/activate
pytest
# Result: 7 passed

# Docker build
docker build -t ezfit-ci .
# Result: Successfully built and tagged ezfit-ci:latest
```

---

## Files changed

| File | Action |
|------|--------|
| `.github/workflows/ci.yml` | Created |
| `.claude/plans/05-github-actions-ci.md` | Created |

No existing files modified.

---

## Remaining items before Azure deployment

- **Stage 6:** Azure Container Registry — log in and push the Docker image
- **Stage 7:** Azure Container Apps — deploy from the registry
- (Optional) Terraform IaC for Azure resource provisioning
- Add `AZURE_CREDENTIALS` and registry secrets to GitHub repository secrets (Stage 6)
