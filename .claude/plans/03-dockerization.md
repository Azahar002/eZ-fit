# Plan 03: Dockerization

## Goal
Package EZ-FIT into a Docker container that builds cleanly and serves the app on port 5001.

## Steps

1. **Create .dockerignore**
   ```
   __pycache__/
   *.pyc
   *.pyo
   ezfit/
   .env
   .git
   .claude
   images/
   ```

2. **Create Dockerfile**
   ```dockerfile
   FROM python:3.11-slim

   WORKDIR /app

   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt

   COPY . .

   RUN useradd -m appuser
   USER appuser

   EXPOSE 5001

   CMD ["python", "app.py"]
   ```

3. **Build and test locally**
   ```bash
   docker build -t ezfit:local .
   docker run -p 5001:5001 \
     -e FLASK_SECRET_KEY=test-key \
     -e FLASK_DEBUG=false \
     -e FLASK_PORT=5001 \
     ezfit:local
   ```
   Visit http://localhost:5001 — landing page must load.

4. **Run DevOps review**
   Use command: `deploy-review` (Dockerfile section only)

5. **Tag for ACR** (after Terraform creates the registry)
   ```bash
   docker tag ezfit:local <acr-name>.azurecr.io/ezfit:v1
   ```

## Done When
- `docker build` exits 0
- Container serves all 3 pages
- No secrets in the image
- Container runs as non-root
