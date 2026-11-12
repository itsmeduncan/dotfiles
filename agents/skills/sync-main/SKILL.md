---
name: sync-main
description: Checkout main, pull latest, remove finished worktrees, prune merged branches
allowed-tools: Bash
---

Sync with the default branch and clean up finished branches and worktrees.

**Run the script once. Never ask the user whether to delete a branch or a
worktree** — the script's rules decide, and it lists whatever it keeps. dg has
said this more than once.

```
bash <this skill's base directory>/sync-main.sh
```

Run it from anywhere inside the repo; it finds the main checkout and the
default branch (`origin/HEAD`, else `main`, else `master`) itself. Add
`--dry-run` only when the user asks to preview.

Then relay its report in a few lines: what it removed, what it kept and why,
any note (a stash to `git stash pop`, a failed pull), and the current tip.

## What the script does

1. Stashes uncommitted work in the main checkout (`sync-main-<date>`).
2. Checks out the default branch, pulls, prunes `origin` and stale worktree records.
3. Keeps a linked worktree that is detached, has tracked changes, or is the
   working directory of a running process (a builder, a precheck, another agent).
4. Treats a branch as finished when any one is true: it is an ancestor of main;
   `git cherry` shows no `+` commit; every commit subject on it is also on main;
   its upstream is `[gone]`. A finished worktree is removed with its branch; a
   finished branch is deleted. Branches named `main`, `master` or `*release*`
   are never touched.
5. Prints a report. It never prompts.

If the report is wrong — it removed or kept the wrong thing — fix the rule in
`sync-main.sh` (and this list), not by hand-deleting around it.
