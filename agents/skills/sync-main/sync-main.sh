#!/usr/bin/env bash
# sync-main: move the main checkout to the default branch, fast-forward it, and
# remove finished worktrees and branches. Never prompts: the rules below decide,
# and whatever they keep is listed in the report with the reason.
#
# Safety rules (each one is a case in test-sync-main.sh):
# - Never stash, and never discard uncommitted or untracked work.
# - A branch is finished only when its CONTENT is already on main: an ancestor,
#   every patch already on main (`git cherry`), or merging it would leave main's
#   tree unchanged (catches squash merges). Commit subjects and a `[gone]`
#   upstream are NOT evidence: both deleted unmerged work.
# - Keep a worktree that is locked, detached, has tracked OR untracked changes,
#   or is the working directory of a running process.
# - Report "Removed" only for a command that succeeded.
#
# Usage: sync-main.sh [--dry-run]   (run from anywhere inside the repo)
#
# Bash 3.2 compatible (macOS /bin/bash): no associative arrays, no mapfile.
# Needs git >= 2.38 (`git merge-tree --write-tree`).

set -uo pipefail

dry_run=0
[ "${1:-}" = "--dry-run" ] && dry_run=1

removed=()
kept=()
notes=()

die() {
  echo "sync-main: $1" >&2
  exit 1
}

# Run a mutating git command, or print it under --dry-run. On failure, keep the
# first line of git's message in $act_err and return non-zero.
act_err=""
act() {
  if ((dry_run)); then
    echo "[dry-run] $*"
    return 0
  fi
  act_err=$("$@" 2>&1 >/dev/null) && return 0
  act_err=$(printf '%s' "$act_err" | head -1)
  return 1
}

main_checkout() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) \
    || die "not inside a git repository; cd into one and run again"
  dirname "$common"
}

default_branch() {
  local ref
  if ref=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null); then
    echo "${ref#origin/}"
  elif git show-ref --verify --quiet refs/heads/main; then
    echo main
  elif git show-ref --verify --quiet refs/heads/master; then
    echo master
  else
    die "no origin/HEAD, main or master branch; set one with: git remote set-head origin --auto"
  fi
}

# Current working directory of every running process, one per line.
process_cwds() {
  lsof -a -d cwd -Fn 2>/dev/null | sed -n 's/^n//p'
}

# True when a running process (a builder, precheck, another agent) uses $1.
in_use() {
  local wt=$1 cwd
  while IFS= read -r cwd; do
    case "$cwd" in "$wt" | "$wt"/*) return 0 ;; esac
  done <<<"$cwds"
  return 1
}

# Merging $1 into $main would produce exactly $main's tree: everything on the
# branch is already on main, even when it landed as a squash merge.
content_landed() {
  local merged
  merged=$(git merge-tree --write-tree "$main" "$1" 2>/dev/null) || return 1
  [ "$(printf '%s\n' "$merged" | head -1)" = "$(git rev-parse "$main^{tree}")" ]
}

# The skill's "finished" test: any one of these means the work landed.
finished() {
  local br=$1 cherry
  git merge-base --is-ancestor "$br" "$main" && return 0
  # A failed `git cherry` must not read as "no unique commits".
  if cherry=$(git cherry "$main" "$br" 2>/dev/null); then
    grep -q '^+' <<<"$cherry" || return 0
  fi
  content_landed "$br"
}

unique_subjects() {
  git log --format='    %s' "$main..$1" | head -5
}

update_main() {
  local current
  current=$(git branch --show-current)
  if [ "$current" != "$main" ] && ! act git checkout "$main"; then
    # git carries uncommitted changes across a checkout when they do not
    # conflict; when they do, it refuses and touches nothing.
    notes+=("stayed on ${current:-a detached HEAD}: checkout of $main failed ($act_err)")
  fi
  act git fetch --prune origin || notes+=("git fetch failed ($act_err); cleanup used the local $main")
  if { [ "$(git branch --show-current)" = "$main" ] || ((dry_run)); } \
    && git rev-parse --verify --quiet "origin/$main" >/dev/null \
    && ! act git merge --ff-only "origin/$main"; then
    # Fast-forward only: unrelated uncommitted files stay in place, and
    # overlapping ones make git refuse without changing anything.
    notes+=("$main not fast-forwarded ($act_err)")
  fi
  act git worktree prune || true
}

# Parse `git worktree list --porcelain` and judge every linked worktree.
clean_worktrees() {
  local wt="" br="" locked=0 line
  while IFS= read -r line; do
    case "$line" in
      "worktree "*) wt=${line#worktree } br="" locked=0 ;;
      "branch refs/heads/"*) br=${line#branch refs/heads/} ;;
      "detached") br="(detached)" ;;
      "locked" | "locked "*) locked=1 ;;
      "")
        [ -n "$wt" ] && [ "$wt" != "$top" ] && clean_worktree "$wt" "$br" "$locked"
        wt=""
        ;;
    esac
  done < <(git worktree list --porcelain && echo)
}

clean_worktree() {
  local wt=$1 br=$2 locked=$3
  if ((locked)); then
    kept+=("worktree $wt (${br:-?}): locked")
  elif [ "$br" = "(detached)" ] || [ -z "$br" ]; then
    kept+=("worktree $wt: detached HEAD")
  elif in_use "$wt"; then
    kept+=("worktree $wt ($br): a running process uses it")
  elif [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
    kept+=("worktree $wt ($br): uncommitted or untracked changes")
  elif ! finished "$br"; then
    kept+=("worktree $wt ($br): unique commits"$'\n'"$(unique_subjects "$br")")
  elif ! act git worktree remove "$wt"; then
    # No --force: git refuses a worktree it considers unclean.
    kept+=("worktree $wt ($br): git refused to remove it ($act_err)")
  elif ! act git branch -D "$br"; then
    removed+=("worktree $wt")
    kept+=("branch $br: delete failed ($act_err)")
  else
    removed+=("worktree $wt and branch $br")
  fi
}

clean_branches() {
  local br wtpath
  while IFS=$'\t' read -r br wtpath; do
    # Skip a branch checked out in a linked worktree (judged above) or still
    # checked out in the main checkout (its checkout of $main failed). A dry
    # run only pretends to switch, so it judges the main checkout's branch.
    [ -n "$wtpath" ] && { [ "$wtpath" != "$top" ] || ((!dry_run)); } && continue
    case "$br" in main | master | "$main" | *release*) continue ;; esac
    if ! finished "$br"; then
      kept+=("branch $br: unique commits"$'\n'"$(unique_subjects "$br")")
    elif act git branch -D "$br"; then
      removed+=("branch $br")
    else
      kept+=("branch $br: delete failed ($act_err)")
    fi
  done < <(git for-each-ref --format='%(refname:short)%09%(worktreepath)' refs/heads)
}

report() {
  local item
  ((dry_run)) && echo "(dry run: nothing was changed)"
  echo "Removed (${#removed[@]}):"
  for item in "${removed[@]+"${removed[@]}"}"; do echo "  - $item"; done
  echo "Kept (${#kept[@]}):"
  for item in "${kept[@]+"${kept[@]}"}"; do echo "  - $item"; done
  for item in "${notes[@]+"${notes[@]}"}"; do echo "Note: $item"; done
  echo "Now on: $(git branch --show-current) @ $(git log -1 --format='%h %s')"
}

top=$(main_checkout)
cd "$top" || die "cannot cd to the main checkout $top"
main=$(default_branch)
cwds=$(process_cwds)

update_main
clean_worktrees
clean_branches
report
