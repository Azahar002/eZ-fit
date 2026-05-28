# Skill: Flask (EZ-FIT context)

## Project Setup
- Entry point: `app.py`
- Port: 5001 (from env `FLASK_PORT`)
- Templates: `templates/` (Jinja2)
- Static files: `static/css/`, `static/js/`
- Virtual env: `ezfit/` (excluded from Docker)

## Key Patterns Used

### App factory pattern (not used — single file is fine for this project)

### Config from environment
```python
import os
from dotenv import load_dotenv
load_dotenv()

app.secret_key = os.environ.get("FLASK_SECRET_KEY")
```

### Rendering templates
```python
return render_template("landing.html", title="EZ-FIT")
```

### Static file URLs in templates (always use this, not hardcoded paths)
```html
<link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
```

### URL linking between pages
```html
<a href="{{ url_for('login') }}">Login</a>
```

## Running the App
```bash
source ezfit/bin/activate
python app.py
# http://localhost:5001
```

## Testing with pytest-flask
```python
def test_landing(client):
    response = client.get("/")
    assert response.status_code == 200
```

## Gotchas
- `host="0.0.0.0"` is required in `app.run()` for Docker networking
- `DEBUG=True` in prod will expose stack traces — always use env var
- Flask's built-in server is fine for this project; no need for gunicorn yet
