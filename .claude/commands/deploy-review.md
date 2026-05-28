# Command: deploy-review

## Purpose
Review all deployment files before pushing to main or triggering a deploy. Catch issues before they hit Azure.

## Steps

1. **Identify deployment files**
   ```
   Dockerfile
   .dockerignore
   terraform/
   .github/workflows/deploy.yml
   ```

2. **Run DevOps review**
   Use agent: `ezfit-devops-reviewer`
   Pass it all deployment files. Ask for a full report.

3. **Verify Docker builds locally**
   ```bash
   docker build -t ezfit:test .
   docker run -p 5001:5001 ezfit:test
   # Visit http://localhost:5001 — landing page should load
   ```

4. **Verify Terraform plan**
   ```bash
   cd terraform/
   terraform init
   terraform plan
   # Review: no unexpected destroys, costs look right
   ```

5. **Verify GitHub Actions YAML**
   - No secrets in plaintext
   - Triggers only on `main`
   - Image tag is not `latest`

6. **Report**
   ```
   Deploy Review: <date>
   Docker: PASS / FAIL
   Terraform plan: X add, X change, X destroy
   Actions YAML: PASS / FAIL
   Blockers: <list or none>
   ```

## Pass Criteria
- Zero `[BLOCKER]` or `[SECURITY]` findings
- Docker container serves the landing page locally
- Terraform plan shows no accidental destroys
