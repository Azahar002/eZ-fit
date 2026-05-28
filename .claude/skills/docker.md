# Skill: Docker (EZ-FIT context)

## Dockerfile Pattern for This Project
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy deps first for layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Non-root user
RUN useradd -m appuser
USER appuser

EXPOSE 5001

CMD ["python", "app.py"]
```

## .dockerignore (must have)
```
__pycache__/
*.pyc
ezfit/          # virtual env — never include in image
.env            # secrets
.git
.claude
images/
```

## Build & Test
```bash
# Build
docker build -t ezfit:local .

# Run with env vars (never bake secrets into the image)
docker run -p 5001:5001 \
  -e FLASK_SECRET_KEY=test-key \
  -e FLASK_DEBUG=false \
  -e FLASK_PORT=5001 \
  ezfit:local

# Visit http://localhost:5001
```

## Tag for ACR
```bash
docker tag ezfit:local <acr>.azurecr.io/ezfit:<run_number>
docker push <acr>.azurecr.io/ezfit:<run_number>
```

## Gotchas
- Never tag with `latest` in CI — use `github.run_number` so deploys are traceable
- `host="0.0.0.0"` must be in `app.run()` — without it the container won't accept traffic
- The `ezfit/` venv directory must be in `.dockerignore` — it's large and wrong for the container
- `python:3.11-slim` is 50–70MB vs `python:3.11` at 900MB — always use slim for Flask
