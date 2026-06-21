# eZ-fit — Web Development Context

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Python Flask 3.1.3 |
| Templating | Jinja2 (extends `base.html`) |
| Styling | Custom CSS (dark theme, no Tailwind) |
| Font | Inter via Google Fonts |
| JS | Vanilla (6 lines — mobile nav toggle only) |
| Server | Gunicorn 23.0.0 |
| Database | SQLite (planned, not yet implemented) |

---

## File Map

```
app.py                          Flask entry point, all routes
requirements.txt                Flask, Gunicorn, Pytest, Werkzeug

templates/
  base.html                     Shared layout: sticky nav + footer
  landing.html                  Homepage (hero, about, services, coaches, why-us)
  login.html                    Login form (UI only)
  register.html                 Registration form (UI only)

static/
  css/style.css                 Full dark theme CSS (~635 lines, CSS variables)
  js/main.js                    Mobile hamburger nav toggle
  img/
    hero.png                    Hero section background
    coach-1..5.png              Coach cards (5 coaches)
    stock-evolve.png            About section collage
    stock-sacrifice.png         About section collage
    stock-tries.png             About section collage
    gym-1..3.png                Services section photo

database/
  __init__.py                   Empty
  db.py                         TODO placeholder — no implementation

tests/
  conftest.py                   Pytest app fixture
  test_routes.py                8 route tests (GET/POST status codes)
```

---

## Routes

| Route | Method | Status |
|-------|--------|--------|
| `/` | GET | ✅ Returns landing page |
| `/health` | GET | ✅ Returns `{"status": "healthy"}` |
| `/login` | GET | ✅ Returns login form |
| `/login` | POST | ⚠️ Accepted but does nothing (TODO) |
| `/register` | GET | ✅ Returns register form |
| `/register` | POST | ⚠️ Accepted but does nothing (TODO) |
| `/logout` | GET | ❌ Returns placeholder string |
| `/profile` | GET | ❌ Returns placeholder string |
| `/workouts/add` | GET/POST | ❌ Returns placeholder string |
| `/workouts/<id>/edit` | GET/POST | ❌ Returns placeholder string |
| `/workouts/<id>/delete` | POST | ❌ Returns placeholder string |

---

## Pages — Completion Status

### Landing Page (`/`) — ✅ Complete
- Hero: headline, subtext, CTA button, 3-stat badge (320+ members, 100+ machines, 50+ coaches)
- About: 4 feature icons + 3-image collage with 3D rotation
- Services: 4 cards (Personal Training, Nutrition, Strength & Cardio, Group Classes) + photo
- Coaches: 5 cards (Ravi, Dan, Ayesh, Maya, Kamal) with social links
- Why Us: 6 benefit icons grid
- Footer: 4-column layout, contact info, social links

### Base Layout — ✅ Complete
- Sticky navbar, brand "eZ-Fit.", menu links
- Hamburger menu for mobile (< 900px)
- 4-column footer (Company, Services, Resources, Support)

### Login Page (`/login`) — ⚠️ UI Only
- Email + password fields, submit button, link to register
- Error message placeholder exists in template
- **Missing:** POST handler logic

### Register Page (`/register`) — ⚠️ UI Only
- Name + email + password fields, submit button, link to login
- Error message placeholder exists in template
- **Missing:** POST handler logic

---

## What Is Pending

### Blocker — Database
- `database/db.py` has only TODO comments
- Need: SQLite connection helper, `init_db()`, `get_db()`, users table schema
- Blocks all auth and feature work

### Authentication
- [ ] Register POST: validate input, hash password (bcrypt/werkzeug), insert user row
- [ ] Login POST: look up user, verify password hash, create Flask session
- [ ] `@login_required` decorator or equivalent for protected routes
- [ ] Logout: clear session, redirect to login
- [ ] CSRF protection (Flask-WTF or manual token)

### User Profile
- [ ] `/profile` template (show name, email, stats)
- [ ] Route: fetch current user from DB, render template

### Workout Tracking
- [ ] Workouts table schema (user_id, exercise, sets, reps, date)
- [ ] Add workout: form + POST handler
- [ ] Edit workout: pre-populated form + POST handler
- [ ] Delete workout: confirm + DELETE handler
- [ ] List workouts on profile page

### Content Fixes
- [ ] Service card descriptions are all identical — write unique copy for each
- [ ] Coach taglines are all identical — write unique tagline per coach
- [ ] Nav links (Classes, Trainers, Blog, Contact US) all point to `#` — either build pages or remove
- [ ] Login/register placeholder text uses "nitish@example.com" — change to generic

### Testing
- [ ] Auth flow tests: register success, register duplicate email, login success, login wrong password
- [ ] Protected route tests: redirect to login when unauthenticated
- [ ] Workout CRUD tests

---

## Local Dev

```bash
# Install dependencies
pip install -r requirements.txt

# Run dev server
flask --app app run --debug

# Or serve on port 3000 (per CLAUDE.md)
node serve.mjs

# Run tests
pytest
```

---

## Design Rules (from CLAUDE.md)

- Primary color: `#c0392b` (red accent)
- Background: `#0f0f0f` (near black)
- Font: Inter (Google Fonts)
- No Tailwind — all custom CSS with CSS variables
- No `transition-all` — animate `transform` and `opacity` only
- Every clickable element needs hover, focus-visible, and active states
- Brand assets live in `brand_assets/` — check there before designing
- Screenshots via `node screenshot.mjs http://localhost:3000` → saved to `temporary screenshots/`
