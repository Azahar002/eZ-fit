# Command: code-review-feature

## Purpose
Run a structured code review on a feature branch or set of changed files before merging.

## Steps

1. **Identify changed files**
   ```bash
   git diff main --name-only
   ```

2. **Run quality review**
   Use agent: `ezfit-quality-reviewer`
   Pass it the changed files and ask for a full quality report.

3. **Run security review**
   Use agent: `ezfit-security-reviewer`
   Pass it the same files and ask for a security report.

4. **Check for missing tests**
   For any changed route or function, confirm a test exists in `tests/`.

5. **Summarize**
   Report back:
   - BLOCKER count (must fix before merge)
   - WARNING count (should fix soon)
   - SUGGESTION count (optional)
   - Test coverage: covered / not covered

## Pass Criteria
- Zero `[BLOCKER]` or `[CRITICAL]` findings
- All changed routes have at least one test

## Output Format
```
Code Review: <feature name>
Quality: X blockers, Y warnings
Security: X critical, Y high
Tests: covered / not covered
Verdict: PASS / FAIL
```
