# Command: test-feature

## Purpose
Run tests for a specific feature and confirm they pass before merging or deploying.

## Steps

1. **Run full test suite**
   ```bash
   pytest tests/ -v
   ```

2. **If tests don't exist yet**
   Use agent: `ezfit-test-writer`
   Tell it which routes or functions need tests, and ask it to write them.

3. **Run only the new tests**
   ```bash
   pytest tests/test_routes.py -v -k "<test_name_pattern>"
   ```

4. **Check for failures**
   - All tests green = proceed
   - Any failure = fix before continuing

5. **Report**
   ```
   Tests run: X
   Passed: X
   Failed: X
   Skipped: X
   ```

## Notes
- Test files live in `tests/`
- Fixture setup is in `tests/conftest.py`
- Do not mock the Flask app — use the real test client from pytest-flask
- If a route has no test yet, that's a gap — flag it
