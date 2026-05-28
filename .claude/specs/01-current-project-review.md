# Spec: Current Project Review

## Status: Baseline (captured 2026-05-28)

---

## What Exists

### Routes (app.py)
| Route | Method | Status |
|---|---|---|
| `/` | GET | Working — renders `landing.html` |
| `/login` | GET | Working — renders `login.html` |
| `/register` | GET | Working — renders `register.html` |
| `/logout` | GET | Placeholder — not implemented |
| `/profile` | GET | Placeholder — not implemented |
| `/workouts/add` | GET/POST | Placeholder — not implemented |
| `/workouts/edit/<id>` | GET/POST | Placeholder — not implemented |
| `/workouts/delete/<id>` | POST | Placeholder — not implemented |

### Templates
- `base.html` — layout shell (6.9K, includes nav and footer)
- `landing.html` — homepage (3.6K)
- `login.html` — login form (1.4K)
- `register.html` — registration form (1.7K)

### Static Assets
- `static/css/style.css` — main stylesheet
- `static/js/main.js` — JavaScript (likely minimal)

### Dependencies
- flask==3.1.3
- werkzeug==3.1.6
- pytest==8.3.5
- pytest-flask==1.3.0

---

## What's Missing (before deployment)

- [ ] `python-dotenv` — config loading from `.env`
- [ ] `.env` file — local config (secret key, debug, port)
- [ ] `host="0.0.0.0"` in `app.run()` — required for Docker
- [ ] `tests/` directory — no tests exist yet
- [ ] `Dockerfile` — not created
- [ ] `.dockerignore` — not created
- [ ] `terraform/` — not created
- [ ] `.github/workflows/` — not created

---

## Known Issues
- `DEBUG=True` is hardcoded (must be env-driven before prod)
- Port 5001 is hardcoded (should come from env)
- No `SECRET_KEY` set (Flask default is insecure)
- `database/db.py` exists but is not connected to any route
