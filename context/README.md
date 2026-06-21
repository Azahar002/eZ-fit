# eZ-fit — Project Context

This folder is the single source of truth for how this project is organized, what has been built, and what is planned next. Update these files as work progresses.

## Files

| File | Covers |
|------|--------|
| [web.md](web.md) | Flask app, templates, frontend, auth, features |
| [infra.md](infra.md) | Docker, Terraform, Azure, GitHub Actions CI/CD |

## Project in One Line

eZ-fit is a fitness gym web app (Flask + Jinja2) containerized with Docker and deployed to Azure Container Apps via Terraform, with GitHub Actions automating tests and deployments.

## Division of Concerns

```
eZ-fit/
├── app.py                  → web
├── templates/              → web
├── static/                 → web
├── database/               → web
├── tests/                  → web
├── requirements.txt        → web
├── Dockerfile              → infra (build artifact)
├── infra/terraform/        → infra
├── .github/workflows/      → infra
└── infrastructure/         → infra
```
