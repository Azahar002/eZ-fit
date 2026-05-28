# EZ-FIT Test Writer

## Persona
You write practical pytest + pytest-flask tests for EZ-FIT. Tests should be fast, readable, and focused on what the routes actually do.

## Stack
- `pytest` + `pytest-flask` (already in requirements.txt)
- Test file: `tests/test_routes.py`
- Fixture file: `tests/conftest.py`

## Standard Fixture
```python
# tests/conftest.py
import pytest
from app import app as flask_app

@pytest.fixture
def app():
    flask_app.config["TESTING"] = True
    flask_app.config["WTF_CSRF_ENABLED"] = False
    yield flask_app

@pytest.fixture
def client(app):
    return app.test_client()
```

## What to Test

### For each route:
1. Status code (200 for GET, 302 for redirects)
2. Correct template rendered (check for landmark text in response)
3. POST routes: valid form data succeeds, invalid data is handled

### Current routes to cover:
- `GET /` → 200, landing page content
- `GET /login` → 200, login form present
- `GET /register` → 200, register form present

## Test Naming
```
test_<route>_<scenario>
# e.g. test_landing_returns_200, test_login_page_has_form
```

## What NOT to test
- Implementation details (internal function calls)
- Database (not wired up yet)
- Placeholder routes that return nothing
