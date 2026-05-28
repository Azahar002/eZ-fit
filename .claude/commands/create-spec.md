# Command: create-spec

## Purpose
Write a spec before implementing any non-trivial feature in EZ-FIT. This ensures alignment before writing code.

## When to Use
- Adding a new page or route
- Changing how templates work
- Any DevOps or deployment change
- Anything that touches more than 2 files

## Steps

1. **Name the feature** — one line description
2. **Why** — what problem does this solve for EZ-FIT?
3. **Scope** — list every file that will change
4. **Out of scope** — explicitly list what this does NOT include
5. **Implementation steps** — numbered, ordered, specific
6. **Verification** — how will you know it worked?

## Spec File Location
Save to: `.claude/specs/<NN>-<feature-name>.md`

## Template
```markdown
# Spec: <Feature Name>

## Why
<one sentence>

## Files Changed
- `<file>` — <what changes>

## Out of Scope
- <item>

## Steps
1. <step>
2. <step>

## Verification
- [ ] <check>
- [ ] <check>
```

## Rule
Do not start implementation until the spec exists and has been reviewed.
