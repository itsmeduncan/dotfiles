---
name: fix-pipeline
description: Diagnose and fix remote CI failures from GitHub Actions logs
argument-hint: "[run-id or URL]"
allowed-tools: Bash, Read, Edit, Grep, Glob
---

Diagnose and fix a failing GitHub Actions run. Accepts an optional run ID or URL as argument.

## Steps

1. **Find the failing run.** If an argument was provided, use it as the run ID/URL. Otherwise:
   ```
   gh run list --branch $(git branch --show-current) --status failure --limit 1
   ```
   Extract the run ID.

2. **Download failed logs:**
   ```
   gh run view <id> --log-failed
   ```

3. **Categorize the failure:** lint, test, build, deploy, dependency, or secrets/permissions.

4. **For fixable issues** (lint, test, build, dependency):
   - Read the relevant local files
   - Apply the fix
   - Run the equivalent command locally to verify:
     - Lint: `ruff check`, `npm run lint`, etc.
     - Test: `pytest <failing_test>`, `npm test -- <failing_test>`
     - Build: `npm run build`, `uv build`, etc.
     - Dependency: `uv lock`, `pnpm install`, etc.

5. **For environment issues** (secrets, permissions, runner config): report what's wrong and what to change in the workflow YAML or repo settings. Do NOT modify workflow files without confirmation.

6. **Stage fixes.** Do NOT commit.

7. **Report:** what failed, root cause, what was fixed, what needs manual action.
