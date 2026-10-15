---
name: sync-main
description: Checkout main, pull latest, remove finished worktrees, prune merged branches
allowed-tools: Bash
---

Sync with main and clean up stale branches and worktrees.

**Do the cleanup. Never ask the user whether to delete a branch or a worktree.**
The rules below decide. Anything the rules keep is listed in the report, not
asked about. dg has said this more than once.

zsh note: never name a shell variable `path` (zsh ties it to `PATH`). Use `wt`.

## Steps

1. **Stash any uncommitted work** in the main checkout:

   ```
   git stash push --include-untracked -m "sync-main-$(date +%F)"
   ```

   Note if anything was stashed.

2. **Switch to main and pull:**

   ```
   git checkout main && git pull
   ```

3. **Prune remote tracking branches and stale worktree records:**

   ```
   git remote prune origin
   git worktree prune
   ```

4. **Remove finished worktrees** (agent worktrees under `.claude/worktrees/`,
   and any other linked worktree). For each one, with its branch `br`:

   - **Keep it** if `git -C "$wt" status --porcelain` shows a tracked change
     (uncommitted work). List it in the report.
   - Otherwise its work is finished when **any** of these is true:
     - `git merge-base --is-ancestor "$br" main` (merged as is), or
     - `git cherry main "$br"` prints no `+` line (cherry-picked or rebased), or
     - every commit subject in `git log --format=%s main.."$br"` also appears in
       `git log --format=%s main` (picked into a batch with conflict fixes), or
     - its remote branch is gone after pruning (merged by the change flow).
   - A finished worktree: `git worktree unlock "$wt" 2>/dev/null; git worktree remove --force "$wt"; git branch -D "$br"`.
   - A clean worktree whose branch still has unique commits: keep it and list
     it with its unique commit subjects.

5. **Delete merged branches** that are not checked out anywhere (two passes):

   ```
   git branch --merged main | grep -v -E '^\*|^\+|main|master|release'
   ```

   Delete each with `git branch -d <branch>`. Then the squash-merged ones:

   ```
   git branch -vv | grep ': gone]' | grep -v -E '^\+|release'
   ```

   Delete each with `git branch -D <branch>`. Apply the same "finished" test as
   step 4 to any branch left over, and delete it when it passes.

6. **Report** (short):
   - Branches and worktrees removed (counts, and names if few)
   - What was kept and why (uncommitted work, or unique commits with their subjects)
   - Whether work was stashed (remind to `git stash pop` if so)
   - Current branch and tip
