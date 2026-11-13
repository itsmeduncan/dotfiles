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
any note (a checkout or fast-forward that git refused, a failed fetch), and the
current tip.

## What the script does

1. Never stashes and never discards uncommitted or untracked work. It checks
   out the default branch only when git can carry the uncommitted changes
   along; otherwise it stays put and says so.
2. Fetches with `--prune`, fast-forwards the default branch (`--ff-only`), and
   prunes stale worktree records.
3. Keeps a linked worktree that is locked, detached, has tracked or untracked
   changes, or is the working directory of a running process (a builder, a
   precheck, another agent).
4. Treats a branch as finished only when its content is already on main: it is
   an ancestor of main; `git cherry` shows no `+` commit; or merging it would
   leave main's tree unchanged (a squash merge). Matching commit subjects and a
   `[gone]` upstream are not evidence. A finished worktree is removed with its
   branch, without `--force`; a finished branch is deleted. Branches named
   `main`, `master` or `*release*` are never touched.
5. Prints a report. It lists a removal only when git did it. It never prompts.

If the report is wrong — it removed or kept the wrong thing — add the case to
`test-sync-main.sh`, then fix the rule in `sync-main.sh` (and this list), not
by hand-deleting around it. Run the tests with
`bash agents/skills/sync-main/test-sync-main.sh`; CI runs them too.
