# Stage 3: Basic Tests — EZ-FIT
Date: 2026-05-28

## What Was Done

Added a minimal `pytest` test suite validating all critical Flask routes before Dockerization. No changes were required to `app.py` or `requirements.txt` — both were already correct from Stage 2.

---

## Tests Added

File: `tests/test_routes.py` (7 tests)

| Test | Route | Method | Assertion |
|------|-------|--------|-----------|
| `test_home_returns_200` | `/` | GET | status == 200 |
| `test_health_returns_200` | `/health` | GET | status == 200 |
| `test_health_returns_json` | `/health` | GET | body == `{"status": "healthy"}` |
| `test_login_get_returns_200` | `/login` | GET | status == 200 |
| `test_register_get_returns_200` | `/register` | GET | status == 200 |
| `test_login_post_not_405` | `/login` | POST | status != 405 |
| `test_register_post_not_405` | `/register` | POST | status != 405 |

---

## Why These Tests Matter Before Docker

- Confirms routes work correctly with the Flask test client before the app is containerized
- Catches any 405 regressions on login/register (the bug found in Stage 1)
- Validates the `/health` endpoint returns the exact JSON Docker/CI health checks will rely on
- Establishes a test baseline so GitHub Actions CI has something to run in Stage 5

---

## How to Run Tests

```bash
# From project root, with venv activated
source ezfit/bin/activate
pytest
```

## Expected Result

```
7 passed
```

---

## Files Changed

| File | Action |
|------|--------|
| `tests/__init__.py` | Created (empty) |
| `tests/conftest.py` | Created — defines `app` fixture for `pytest-flask` |
| `tests/test_routes.py` | Created — 7 route tests |
| `.claude/plans/03-basic-tests.md` | Created — this file |
| `app.py` | No change |
| `requirements.txt` | No change |

---

## Remaining Items Before Dockerization (Stage 4)

- [ ] Add `host="0.0.0.0"` to `app.run()` in `app.py` (required for Docker networking)
- [ ] Create `.dockerignore` (exclude `ezfit/`, `__pycache__/`, `.git/`, `images/`)
- [ ] Write `Dockerfile`
- [ ] Stage 5 (after Docker): Wire up GitHub Actions CI to run `pytest` on push
