---
name: fix-ci
description: Run repo linters and type checkers locally, fix all errors until clean
allowed-tools: Bash, Read, Edit, Grep, Glob
---

Fix all lint, format, and type errors in the current repo until CI would pass.

## Steps

1. **Detect repo type:**
   - Python (`pyproject.toml`):
     ```
     ruff check app/ tests/ --fix
     ruff format app/ tests/
     mypy app/ --ignore-missing-imports
     ```
   - TypeScript (`package.json`):
     ```
     npm run lint -- --fix
     npx tsc --noEmit
     ```
   - Terraform (`*.tf`):
     ```
     mise exec -- terraform fmt -recursive
     mise exec -- terraform validate
     ```

2. **Review remaining errors.** For each error that auto-fix couldn't resolve:
   - Read the failing file
   - Understand the error
   - Fix it manually

3. **Re-run all linters** to confirm clean. Repeat step 2 if anything remains.

4. **Stage all fixes.**

5. **Report summary:** what was broken, what was fixed, final status.

Do NOT commit. Only lint, fix, and stage.
