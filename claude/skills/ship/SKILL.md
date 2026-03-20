---
name: ship
description: Lint, commit with git aqen, push, and create PR in one shot
allowed-tools: Bash, Read, Edit, Grep, Glob
---

Ship the current changes. Argument is the intent description for the commit.

## Steps

1. **Detect repo type** from current directory:
   - Python (`pyproject.toml`): `ruff check app/ tests/ --fix` → `ruff format app/ tests/` → `mypy app/ --ignore-missing-imports`
   - TypeScript (`package.json`): `npm run lint -- --fix` → `npx tsc --noEmit`
   - Terraform (`*.tf`): `mise exec -- terraform fmt -recursive` → `mise exec -- terraform validate`

2. **Auto-fix lint issues.** Re-run linters until fully clean. If manual fixes needed, make them.

3. **Stage changed files.** Never stage `.env`, `credentials.json`, or secrets.

4. **Commit** with:
   ```
   git aqen commit --intent "$ARGUMENTS" --model "claude-opus-4-6"
   ```

5. **Push:**
   ```
   git push -u origin HEAD
   ```

6. **Create PR** with `gh pr create` — include a summary section and test plan. Use a HEREDOC for the body.

7. **Return the PR URL.**

If on `main`, create a branch first named after the intent (kebab-case, max 50 chars).
