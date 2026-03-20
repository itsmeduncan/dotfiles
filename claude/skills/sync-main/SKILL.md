---
name: sync-main
description: Checkout main, pull latest, prune merged branches
allowed-tools: Bash
---

Sync with main and clean up stale branches.

## Steps

1. **Stash any uncommitted work:**
   ```
   git stash --include-untracked
   ```
   Note if anything was stashed.

2. **Switch to main and pull:**
   ```
   git checkout main && git pull
   ```

3. **List merged branches:**
   ```
   git branch --merged main | grep -v -E '^\*|main|master'
   ```

4. **Delete merged branches** (skip any that fail):
   ```
   git branch -d <branch>
   ```

5. **Prune remote tracking branches:**
   ```
   git remote prune origin
   ```

6. **Report:**
   - Branches deleted
   - Branches still open
   - Whether work was stashed (remind to `git stash pop` if so)
   - Current status
