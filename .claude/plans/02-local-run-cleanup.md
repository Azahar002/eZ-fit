# Plan 02: Local Run Cleanup

## Goal
Make the app run cleanly on localhost in a way that's ready for containerization. No hardcoded config, no debug in prod.

## Steps

1. **Add python-dotenv**
   Add to `requirements.txt`:
   ```
   python-dotenv==1.0.1
   ```

2. **Create .env file**
   ```
   FLASK_SECRET_KEY=dev-secret-change-in-prod
   FLASK_DEBUG=true
   FLASK_PORT=5001
   ```
   Add `.env` to `.gitignore` if not already there.

3. **Update app.py**
   Load config from environment:
   ```python
   from dotenv import load_dotenv
   import os
   load_dotenv()

   app.secret_key = os.environ.get("FLASK_SECRET_KEY", "fallback-key")
   debug = os.environ.get("FLASK_DEBUG", "false").lower() == "true"
   port = int(os.environ.get("FLASK_PORT", 5001))

   if __name__ == "__main__":
       app.run(debug=debug, port=port, host="0.0.0.0")
   ```
   Note: `host="0.0.0.0"` is required for Docker.

4. **Verify local run still works**
   ```bash
   pip install -r requirements.txt
   python app.py
   ```
   All 3 pages load at http://localhost:5001.

5. **Run tests**
   ```bash
   pytest tests/ -v
   ```

## Done When
- App starts with no warnings
- Config is fully env-driven
- Tests pass
- `.env` is gitignored
