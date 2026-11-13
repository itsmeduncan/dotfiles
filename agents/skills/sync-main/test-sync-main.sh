#!/usr/bin/env bash
# Regression tests for sync-main.sh. Builds a throwaway repo with a bare origin
# and every branch/worktree shape the script must keep or remove, runs the
# script, and checks the result. No network; nothing outside a temp directory.
#
# Usage: bash agents/skills/sync-main/test-sync-main.sh

# Each check passes its condition as a single-quoted string that `check`
# evaluates later, so variables there are read through eval on purpose.
# shellcheck disable=SC2016,SC2034

set -euo pipefail

script="$(cd "$(dirname "$0")" && pwd)/sync-main.sh"
root=$(mktemp -d "${TMPDIR:-/tmp}/sync-main-test.XXXXXX")
trap 'rm -rf "$root"' EXIT

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com

failures=0
pass() { echo "ok   - $1"; }
fail() {
  echo "FAIL - $1"
  failures=$((failures + 1))
}
check() { if eval "$2"; then pass "$1"; else fail "$1"; fi; }

commit() { # commit <file> <content> <subject>
  printf '%s\n' "$2" >"$1"
  git add "$1"
  git commit -q --allow-empty-message -m "$3"
}

# --- fixture ---------------------------------------------------------------
cd "$root"
git init -q --bare -b main origin.git
git clone -q origin.git repo 2>/dev/null
cd repo
git checkout -q -b main
commit README.md "hello" "Update README.md"
git push -q -u origin main
git remote set-head origin main

# Must be REMOVED.
git branch merged main # ancestor of main

git checkout -q -b squashed main # squash-merged: content on main, patches differ
commit s1.txt one "squash part 1"
commit s2.txt two "squash part 2"
git checkout -q main
git merge -q --squash squashed && git commit -q -m "Squash: squashed"

git checkout -q -b picked main~1 # cherry-picked: same patch, new SHA
commit p.txt pick "pick me"
git checkout -q main
git cherry-pick picked >/dev/null

git worktree add -q -b wt-merged ../wt-merged main # clean worktree, merged

# Must be KEPT.
git branch release/1.0 main~2
git checkout -q -b same-subject main # same subject as main, different content
commit other.txt different "Update README.md"

git checkout -q -b no-message main
commit nomsg.txt unique ""

git checkout -q -b gone main # squash-landed, remote deleted, then new work
commit g1.txt first "gone part 1"
git push -q -u origin gone
git checkout -q main
git merge -q --squash gone && git commit -q -m "Squash: gone"
git push -q origin --delete gone
git checkout -q gone
commit g2.txt unpushed "gone part 2, never pushed"
git checkout -q main

git worktree add -q -b wt-untracked ../wt-untracked main
echo precious >../wt-untracked/new.py

git worktree add -q -b wt-modified ../wt-modified main
echo edit >>../wt-modified/README.md

git worktree add -q -b wt-locked ../wt-locked main
git worktree lock --reason "agent running" ../wt-locked

git worktree add -q --detach ../wt-detached main

git push -q origin main

# origin moves ahead, so the script must fast-forward main.
git clone -q ../origin.git ../other 2>/dev/null
(cd ../other && commit upstream.txt up "Upstream change" && git push -q origin main)

# The main checkout sits on a finished branch with an unrelated uncommitted
# edit and an untracked file, which must survive the switch to main.
git checkout -q merged
echo "local edit" >>README.md
echo "scratch" >untracked-note.txt

# --- dry run changes nothing --------------------------------------------------
before=$(
  git for-each-ref --format='%(refname) %(objectname)' refs/heads
  git worktree list --porcelain
  git status --porcelain
)
bash "$script" --dry-run >"$root/dry.out"
after=$(
  git for-each-ref --format='%(refname) %(objectname)' refs/heads
  git worktree list --porcelain
  git status --porcelain
)
check "dry run changes nothing" '[ "$before" = "$after" ]'

# --- real run -----------------------------------------------------------------
bash "$script" >"$root/run.out" 2>&1 || fail "script exited non-zero"

has_branch() { git show-ref --verify --quiet "refs/heads/$1"; }
for b in merged squashed picked wt-merged; do
  check "removes finished branch $b" '! has_branch "$b"'
done
check "removes clean merged worktree" '[ ! -d ../wt-merged ]'
for b in release/1.0 same-subject no-message gone wt-untracked wt-modified wt-locked; do
  check "keeps branch $b" 'has_branch "$b"'
done
check "keeps untracked work" '[ -f ../wt-untracked/new.py ]'
check "keeps modified worktree" 'grep -q edit ../wt-modified/README.md'
check "keeps locked worktree" '[ -d ../wt-locked ]'
check "keeps detached worktree" '[ -d ../wt-detached ]'
check "main checkout is on main" '[ "$(git branch --show-current)" = main ]'
check "main fast-forwarded to origin" '[ "$(git rev-parse main)" = "$(git rev-parse origin/main)" ] && [ -f upstream.txt ]'
check "uncommitted edit kept in place" 'grep -q "local edit" README.md'
check "untracked file kept in place" '[ -f untracked-note.txt ]'
check "no stash created" '[ -z "$(git stash list)" ]'
check "report lists 4 removals" 'grep -q "^Removed (4):" "$root/run.out"'

# --- second run is a no-op ----------------------------------------------------
bash "$script" >"$root/run2.out" 2>&1
check "second run removes nothing" 'grep -q "^Removed (0):" "$root/run2.out"'

if ((failures)); then
  echo "--- first run output:"
  cat "$root/run.out"
  echo "$failures check(s) failed"
  exit 1
fi
echo "all checks passed"
