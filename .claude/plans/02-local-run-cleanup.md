# Stage 2 — Local Run Cleanup

**Date:** 2026-05-28
**Branch:** project-review
**Based on:** Stage 1 audit (`01-project-review.md`)

---

## What Was Changed

### `app.py`

- Added `jsonify` to Flask import
- Added `/health` route returning `{"status": "healthy"}` with HTTP 200
- Updated `/login` to accept `GET` and `POST` — re-renders `login.html` on both; POST no longer returns 405
- Updated `/register` to accept `GET` and `POST` — re-renders `register.html` on both; POST no longer returns 405
- Added `# TODO` comments on both auth routes marking where real auth goes in Step 3

### `requirements.txt`

- Added `gunicorn==23.0.0` — required for production WSGI server in Docker

### `.gitignore`

- Added `ezfit/` — excludes the local virtual environment from git and future Docker build context
- Added `.env` — excludes secrets file
- Added `__pycache__/` — excludes Python bytecode cache
- Added `.pytest_cache/` — excludes pytest cache

---

## Why It Was Changed

| Change | Reason |
|--------|--------|
| `/health` route | Required by Docker health checks and container orchestrators |
| POST on `/login` + `/register` | Forms submit via POST; GET-only routes returned 405 |
| `gunicorn` in requirements | `flask run` dev server is not safe for production or Docker |
| `ezfit/` in `.gitignore` | 300MB+ venv must not be committed or copied into Docker image |
| `.env` in `.gitignore` | Secrets must never be committed |
| `__pycache__/` + `.pytest_cache/` in `.gitignore` | Generated files; not source code |

---

## Local Run

```bash
cd /Users/azzu/Desktop/eZ-fit
source ezfit/bin/activate
pip install -r requirements.txt
python app.py
```

## Local Website URL

```
http://127.0.0.1:5001
```

## Health Check URL

```
http://127.0.0.1:5001/health
→ {"status": "healthy"}
```

---

## Verification Results

| Endpoint | Method | Result |
|----------|--------|--------|
| `/` | GET | 200 — renders landing.html |
| `/health` | GET | 200 — `{"status": "healthy"}` (application/json) |
| `/login` | GET | 200 — renders login.html |
| `/register` | GET | 200 — renders register.html |
| `/login` | POST | 200 — renders login.html (no 405) |
| `/register` | POST | 200 — renders register.html (no 405) |

---

## Remaining Issues Before Dockerization (Stage 3)

| # | Issue | Blocking Docker? |
|---|-------|-----------------|
| 1 | No `host="0.0.0.0"` in `app.run()` | Yes — add in Stage 3 |
| 2 | No `wsgi.py` | No — Dockerfile can call gunicorn directly |
| 3 | `images/` folder has 20 unreferenced PNGs | No — gitignored; review and clean up later |
| 4 | `main.js` is a comment-only stub | No — not blocking |
| 5 | No `.dockerignore` | Yes — add in Stage 3 (must exclude `ezfit/`, `images/`, `.DS_Store`) |
| 6 | Real auth not implemented | No — deferred to Step 3 of curriculum |
