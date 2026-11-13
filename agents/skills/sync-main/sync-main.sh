#!/usr/bin/env bash
# sync-main: switch the main checkout to the default branch, pull, and remove
# finished worktrees and branches. Never prompts: the rules below decide, and
# whatever they keep is listed in the report with the reason.
#
# Usage: sync-main.sh [--dry-run]   (run from anywhere inside the repo)
#
# Bash 3.2 compatible (macOS /bin/bash): no associative arrays, no mapfile.

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

# Run a mutating git command, or print it under --dry-run.
act() {
  if ((dry_run)); then
    echo "[dry-run] $*"
  else
    "$@" >/dev/null 2>&1
  fi
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

# Every commit subject on $br but not on $main also appears on $main
# (picked into a batch with conflict fixes).
subjects_landed() {
  local br=$1 subject
  while IFS= read -r subject; do
    [ -z "$subject" ] && continue
    grep -Fxq -- "$subject" "$main_subjects" || return 1
  done < <(git log --format=%s "$main..$br")
  return 0
}

# The skill's "finished" test: any one of these means the work landed.
finished() {
  local br=$1 cherry
  git merge-base --is-ancestor "$br" "$main" && return 0
  # A failed `git cherry` must not read as "no unique commits".
  if cherry=$(git cherry "$main" "$br" 2>/dev/null); then
    grep -q '^+' <<<"$cherry" || return 0
  fi
  subjects_landed "$br" && return 0
  [ "$(git for-each-ref --format='%(upstream:track)' "refs/heads/$br")" = "[gone]" ] && return 0
  return 1
}

unique_subjects() {
  git log --format='    %s' "$main..$1" | head -5
}

stash_main_checkout() {
  [ -z "$(git status --porcelain)" ] && return
  act git stash push --include-untracked -m "sync-main-$(date +%F)"
  notes+=("stashed uncommitted work in the main checkout; restore it with: git stash pop")
}

update_main() {
  act git checkout "$main" || die "cannot check out $main; resolve the error above and run again"
  if ! act git pull; then
    notes+=("git pull failed (offline or diverged); cleanup used the local $main")
  fi
  act git remote prune origin
  act git worktree prune
}

clean_worktrees() {
  local wt="" br="" line
  while IFS= read -r line; do
    case "$line" in
      "worktree "*) wt=${line#worktree } br="" ;;
      "branch refs/heads/"*) br=${line#branch refs/heads/} ;;
      "detached") br="(detached)" ;;
      "")
        [ -n "$wt" ] && [ "$wt" != "$top" ] && clean_worktree "$wt" "$br"
        wt=""
        ;;
    esac
  done < <(git worktree list --porcelain && echo)
}

clean_worktree() {
  local wt=$1 br=$2
  if [ "$br" = "(detached)" ] || [ -z "$br" ]; then
    kept+=("worktree $wt: detached HEAD")
  elif in_use "$wt"; then
    kept+=("worktree $wt ($br): a running process uses it")
  elif [ -n "$(git -C "$wt" status --porcelain --untracked-files=no 2>/dev/null)" ]; then
    kept+=("worktree $wt ($br): uncommitted changes")
  elif finished "$br"; then
    act git worktree unlock "$wt"
    act git worktree remove --force "$wt"
    act git branch -D "$br"
    removed+=("worktree $wt and branch $br")
  else
    kept+=("worktree $wt ($br): unique commits"$'\n'"$(unique_subjects "$br")")
  fi
}

clean_branches() {
  local br wtpath
  while IFS=$'\t' read -r br wtpath; do
    # Skip branches checked out in a kept worktree. The main checkout's branch
    # is judged too: update_main moved it to $main (a dry run only pretends).
    [ -n "$wtpath" ] && [ "$wtpath" != "$top" ] && continue
    case "$br" in main | master | "$main" | *release*) continue ;; esac
    if finished "$br"; then
      act git branch -D "$br"
      removed+=("branch $br")
    else
      kept+=("branch $br: unique commits"$'\n'"$(unique_subjects "$br")")
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
main_subjects=$(mktemp "${TMPDIR:-/tmp}/sync-main.XXXXXX")
trap 'rm -f "$main_subjects"' EXIT

stash_main_checkout
update_main
git log --format=%s "$main" >"$main_subjects"
clean_worktrees
clean_branches
report
