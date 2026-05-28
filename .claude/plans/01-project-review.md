# Plan 01: Project Review

## Goal
Audit the current EZ-FIT project and document exactly what exists, what works, and what needs fixing before any deployment work begins.

## Steps

1. **Read app.py**
   - List all routes and their status (working / placeholder)
   - Note the port and debug settings
   - Identify any hardcoded values that should be env vars

2. **Read requirements.txt**
   - Are all packages needed?
   - Are versions pinned?
   - Is anything missing (e.g., `python-dotenv` for .env support)?

3. **Check templates/**
   - Does every template extend `base.html`?
   - Are static file references correct (`url_for`)?
   - Do login and register forms have proper `action` and `method`?

4. **Check static/**
   - Is `style.css` linked in `base.html`?
   - Is `main.js` used or empty?

5. **Run the app locally**
   ```bash
   cd /Users/azzu/Desktop/eZ-fit
   source ezfit/bin/activate
   python app.py
   # Visit http://localhost:5001
   ```
   Confirm: landing, login, register all load without error.

6. **Document findings**
   Write results to `.claude/specs/01-current-project-review.md`

## Output
A clear list of: what works, what's broken, what's missing.
This becomes the baseline before Plan 02.
