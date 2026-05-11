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

3. **Prune remote tracking branches:**

   ```
   git remote prune origin
   ```

4. **Delete merged branches** (two passes):

   First, delete branches that are ancestor-merged into main:

   ```
   git branch --merged main | grep -v -E '^\*|main|master|release'
   ```

   Delete each with `git branch -d <branch>`.

   Then, detect squash-merged branches (common with GitHub PRs). For each remaining local branch, check if its remote tracking branch is gone after pruning:

   ```
   git branch -vv | grep ': gone]' | grep -v 'release'
   ```

   Delete each with `git branch -D <branch>`.

5. **Report:**
   - Branches deleted
   - Branches still open
   - Whether work was stashed (remind to `git stash pop` if so)
   - Current status
