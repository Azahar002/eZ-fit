# Stage 1 — EZ-FIT Project Review

**Date:** 2026-05-28
**Branch:** project-review
**Reviewer:** Claude Code (Stage 1 — read-only audit)

---

## 1. Current Project Structure

```
eZ-fit/
├── app.py                     # Flask application entry point
├── requirements.txt           # Python dependencies
├── .gitignore                 # Ignores .DS_Store, *.png, images/
├── .DS_Store                  # macOS metadata file (on disk, not tracked)
├── templates/
│   ├── base.html              # Shared base layout (navbar + footer)
│   ├── landing.html           # Home / marketing page
│   ├── login.html             # Sign-in form
│   └── register.html          # Account creation form
├── static/
│   ├── css/
│   │   └── style.css          # Complete CSS (635 lines, all pages)
│   └── js/
│       └── main.js            # Placeholder (1 comment, no code)
├── images/                    # 20 PNG files (gitignored, not referenced in templates)
│   ├── Landing-1.png
│   ├── landing-2.png
│   ├── landing-3.png
│   ├── landing-4.png
│   ├── landing-5.png
│   ├── landing-6.png
│   ├── undefined - Imgur.png
│   └── stock/                 # 13 stock images (all named "undefined - Imgur*.png")
├── database/
│   ├── __init__.py            # Empty file
│   └── db.py                  # Comment-only placeholder (no working code)
└── ezfit/                     # Python 3.11 virtual environment (venv)
```

**Missing configuration files:** `.env`, `config.py`, `wsgi.py`, `Procfile`, `Dockerfile`, `docker-compose.yml` — none exist.

---

## 2. Application Entry Point

**File:** `app.py`

`app.py` is the correct and only Flask entry point. It:
- Creates the Flask app with `app = Flask(__name__)`
- Defines all 8 routes
- Runs the dev server on port 5001 with debug mode enabled

```python
if __name__ == "__main__":
    app.run(debug=True, port=5001)
```

**Imports:** Only `flask.Flask` and `flask.render_template` — minimal and correct for current functionality.

---

## 3. Current Routes

| Route | Function | Method | Returns |
|-------|----------|--------|---------|
| `/` | `landing()` | GET | `render_template("landing.html")` |
| `/register` | `register()` | GET | `render_template("register.html")` |
| `/login` | `login()` | GET | `render_template("login.html")` |
| `/logout` | `logout()` | GET | Plain text: `"Logout — coming in Step 3"` |
| `/profile` | `profile()` | GET | Plain text: `"Profile page — coming in Step 4"` |
| `/workouts/add` | `add_workout()` | GET | Plain text: `"Add workout — coming in Step 7"` |
| `/workouts/<int:id>/edit` | `edit_workout(id)` | GET | Plain text: `"Edit workout — coming in Step 8"` |
| `/workouts/<int:id>/delete` | `delete_workout(id)` | GET | Plain text: `"Delete workout — coming in Step 9"` |

**No `/health` route exists.**

The login and register HTML forms submit via POST (`action="/login"` and `action="/register"`), but both Flask routes only accept GET. Submitting either form currently returns **405 Method Not Allowed**.

---

## 4. Templates and Static Assets

### Template Structure

All templates use Flask's `url_for()` for static file and route references — correct pattern throughout.

**Inheritance chain:**
```
base.html
├── landing.html
├── login.html
└── register.html
```

`base.html` provides:
- Google Fonts (DM Serif Display, DM Sans)
- CSS link via `url_for('static', filename='css/style.css')`
- Navbar with brand and two nav links (Sign in, Get started)
- `{% block content %}` for page body
- Footer with brand, columns (Company, Services, Resources, Support), and social links
- JS script via `url_for('static', filename='js/main.js')`
- `{% block scripts %}` for page-level scripts

### Static File References — All Resolved Correctly

| Template | Reference | File Exists? |
|----------|-----------|-------------|
| `base.html` | `url_for('static', filename='css/style.css')` | Yes |
| `base.html` | `url_for('static', filename='js/main.js')` | Yes |

### Route References in Templates — All Resolved Correctly

| Template | `url_for()` call | Route defined? |
|----------|-----------------|---------------|
| `base.html` | `url_for('landing')` | Yes |
| `base.html` | `url_for('login')` | Yes |
| `base.html` | `url_for('register')` | Yes |
| `landing.html` | `url_for('register')` | Yes |
| `landing.html` | `url_for('login')` | Yes |
| `login.html` | `url_for('register')` | Yes |
| `register.html` | `url_for('login')` | Yes |

**No broken static paths. No broken route references.**

### Unused Image Assets

The `images/` folder contains 20 PNG files. None are referenced in any template. No `<img>` tags exist in any HTML file. These images are also gitignored (`*.png` and `images/` in `.gitignore`), meaning they are local-only assets.

The stock images are poorly named (`undefined - Imgur.png`, `undefined - Imgur (1).png`, etc.) and appear to be downloaded placeholder files with no current use.

---

## 5. Requirements and Dependencies

**File:** `requirements.txt`

```
flask==3.1.3
werkzeug==3.1.6
pytest==8.3.5
pytest-flask==1.3.0
```

| Dependency | Status | Note |
|------------|--------|------|
| `flask==3.1.3` | Correct | Current stable Flask |
| `werkzeug==3.1.6` | Correct | Flask's WSGI toolkit (auto-installed, but pinning is fine) |
| `pytest==8.3.5` | Acceptable | Pinned; fine for a teaching project |
| `pytest-flask==1.3.0` | Acceptable | Flask test client integration |
| `gunicorn` | Missing | Required for production and Docker |
| `python-dotenv` | Missing | Required to load `.env` file for secrets |

No ORM or SQLite dependency is present — consistent with the fact that the database is not yet implemented.

---

## 6. Database Usage

**Folder:** `database/`

- `database/__init__.py` — empty file, no code
- `database/db.py` — contains only comments describing what students should implement:

```python
# Students will write this file in Step 1 — Database Setup
# This file should contain:
#   get_db()   — returns a SQLite connection with row_factory and foreign keys enabled
#   init_db()  — creates all tables using CREATE TABLE IF NOT EXISTS
#   seed_db()  — inserts sample data for development
```

**The database is not used by any route.** No SQLite `.db` file exists. No imports of `database/` anywhere in `app.py`.

**For current portfolio deployment:** The database can be ignored. The three rendered pages (`/`, `/login`, `/register`) work without any database connection. The placeholder routes (`/logout`, `/profile`, etc.) return static strings and also need no database.

---

## 7. Local Run Status

### Command to Run Locally

```bash
cd /Users/azzu/Desktop/eZ-fit
source ezfit/bin/activate
python app.py
```

### Local URL

```
http://127.0.0.1:5001
```

### Working Pages

| URL | Status |
|-----|--------|
| `http://127.0.0.1:5001/` | Renders landing.html |
| `http://127.0.0.1:5001/login` | Renders login.html |
| `http://127.0.0.1:5001/register` | Renders register.html |
| `http://127.0.0.1:5001/logout` | Returns plain text string |
| `http://127.0.0.1:5001/profile` | Returns plain text string |
| `http://127.0.0.1:5001/workouts/add` | Returns plain text string |

### Health Endpoint

**No `/health` endpoint exists.** This is required before Dockerization so container orchestrators (Docker, ECS, Kubernetes) can verify the app is alive.

---

## 8. Issues Found

Listed in order of priority for Dockerization:

| # | Issue | Impact |
|---|-------|--------|
| 1 | No `/health` endpoint | Docker health checks will fail without it |
| 2 | `gunicorn` not in requirements.txt | Cannot use a production WSGI server in Docker |
| 3 | No `python-dotenv` | Cannot load secrets/config from `.env` in any environment |
| 4 | Login and register accept GET only | Submitting either form returns 405 Method Not Allowed |
| 5 | `ezfit/` venv is in project root | Must be excluded from Docker build context via `.dockerignore` |
| 6 | No `.dockerignore` | Docker COPY will include `ezfit/`, `images/`, `.DS_Store` — bloating the image |
| 7 | No `wsgi.py` or `Procfile` | No production entry point defined yet |
| 8 | Stock images named `undefined - Imgur*.png` | Not blocking, but should be cleaned up or documented |
| 9 | Footer links are all `href="#"` | Placeholder links; not blocking |
| 10 | `main.js` is a comment-only placeholder | Not blocking — no JS functionality needed yet |

---

## 9. Recommendation for Stage 2

Before adding Docker, fix these in order:

**Must fix (blocks Docker):**

1. Add `gunicorn` to `requirements.txt`
2. Add `python-dotenv` to `requirements.txt`
3. Add a `/health` route to `app.py` that returns `{"status": "ok"}` with HTTP 200
4. Create a `.dockerignore` that excludes `ezfit/`, `images/`, `.DS_Store`, `__pycache__/`, `*.pyc`, `.git/`

**Should fix (good practice before Docker):**

5. Add POST handlers to `/login` and `/register` — even if they just re-render the form with a placeholder message — so the forms don't 405

**Can defer to later stages:**

- Database implementation (Step 1 in the teaching curriculum)
- `wsgi.py` (Dockerfile can call gunicorn directly without it)
- Image cleanup (images are gitignored and not referenced in any template)

Once items 1–4 above are done, the app is ready for a basic `Dockerfile` + `docker-compose.yml` in Stage 2.
