#!/usr/bin/env bash
# Behavior tests for the Claude Code hooks and the status line. Fixtures live in
# a temp dir; nothing touches the real ~/.claude or any repo.
#
# Usage: bash claude/hooks/test-hooks.sh

# Each check passes its condition as a single-quoted string that `check`
# evaluates later, so variables there are read through eval on purpose.
# shellcheck disable=SC2016,SC2034

set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
statusline="$here/../statusline.sh"
root=$(mktemp -d "${TMPDIR:-/tmp}/hook-test.XXXXXX")
trap 'rm -rf "$root"' EXIT
export TMPDIR="$root/tmp"
mkdir -p "$TMPDIR"
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com

failures=0
check() {
  if eval "$2"; then echo "ok   - $1"; else
    echo "FAIL - $1"
    failures=$((failures + 1))
  fi
}

# run_hook <script> <json>: feed JSON through a FIFO whose write end stays open
# while the script runs, as Claude Code sometimes does, and kill the script
# after 2 s. A script that waits for EOF fails here with exit 142 (SIGALRM).
run_hook() {
  local fifo="$root/fifo.$$.$RANDOM" pid rc
  mkfifo "$fifo"
  perl -e 'alarm 2; exec @ARGV' sh "$1" <"$fifo" &
  pid=$!
  exec 3>"$fifo"
  printf '%s\n' "$2" >&3
  wait "$pid"
  rc=$?
  exec 3>&-
  rm -f "$fifo"
  return "$rc"
}
bash_cmd() { jq -cn --arg c "$1" '{tool_name: "Bash", tool_input: {command: $c}}'; }

# --- bash-guard ----------------------------------------------------------------
guard="$here/bash-guard.sh"
blocked() {
  run_hook "$guard" "$(bash_cmd "$1")" >/dev/null 2>&1
  local rc=$?
  [ "$rc" -eq 2 ]
}
allowed() { run_hook "$guard" "$(bash_cmd "$1")" >/dev/null 2>&1; }
for c in "pkill -f vite" "killall node" "cd app && pkill node" "sudo pkill x" \
  "git commit --no-verify -m x" "git -c core.hooksPath=/dev/null commit -m x" \
  "git push --force origin main" "git push -f origin HEAD:master" "git push origin +main" \
  "git push --force-with-lease origin main"; do
  check "bash-guard blocks: $c" 'blocked "$c"'
done
for c in "git status" "rg -n pkill src" "pgrep -f vite" "echo killall is banned" \
  "git push origin main" "git push --force-with-lease origin feature/main-fix"; do
  check "bash-guard allows: $c" 'allowed "$c"'
done

# --- scriptorium-session -----------------------------------------------------------
repo_with_origin() {
  git init -q "$1" && git -C "$1" remote add origin "$2"
}
repo_with_origin "$root/forge" "duncan@scriptorium.tail1cf291.ts.net:git/inkhold.git"
repo_with_origin "$root/gh" "git@github.com:wellrunpartners/cockpit.git"
out=$(run_hook "$here/scriptorium-session.sh" "{\"cwd\": \"$root/forge\"}")
check "scriptorium-session speaks in a forge repo" 'printf "%s" "$out" | jq -e ".hookSpecificOutput.additionalContext | test(\"scriptorium-protocol\")" >/dev/null'
out=$(run_hook "$here/scriptorium-session.sh" "{\"cwd\": \"$root/gh\"}")
check "scriptorium-session is silent in a GitHub repo" '[ -z "$out" ]'

# --- context-guard -------------------------------------------------------------
usage_line() { jq -cn --argjson n "$1" '{type: "assistant", message: {usage: {input_tokens: 10, cache_read_input_tokens: $n, cache_creation_input_tokens: 0}}}'; }
usage_line 450000 >"$root/big.jsonl"
usage_line 300000 >"$root/small.jsonl"
ctx() { run_hook "$here/context-guard.sh" "{\"session_id\": \"$1\", \"transcript_path\": \"$2\"}"; }
out=$(ctx s1 "$root/big.jsonl")
check "context-guard warns above 400k" 'printf "%s" "$out" | jq -e ".hookSpecificOutput.additionalContext | test(\"450k\")" >/dev/null'
out=$(ctx s1 "$root/big.jsonl")
check "context-guard warns once per 100k step" '[ -z "$out" ]'
out=$(ctx s2 "$root/small.jsonl")
check "context-guard is silent below 400k" '[ -z "$out" ]'

# --- commonplace-capture ---------------------------------------------------------
cap() { run_hook "$here/commonplace-capture.sh" "{\"session_id\": \"$1\", \"transcript_path\": \"$2\", \"stop_hook_active\": ${3:-false}}"; }
printf '%s\n' '{"type":"tool_use","name":"Edit"}' >"$root/edit.jsonl"
printf '%s\n' '{"type":"tool_use","name":"Read"}' >"$root/read.jsonl"
printf '%s\n%s\n' '{"type":"tool_use","name":"Edit"}' '{"type":"tool_use","name":"mcp__commonplace-personal__add_memory"}' >"$root/wrote.jsonl"
out=$(cap c1 "$root/edit.jsonl")
check "capture nudges after an edit" 'printf "%s" "$out" | jq -e ".decision == \"block\"" >/dev/null'
out=$(cap c1 "$root/edit.jsonl")
check "capture nudges only once" '[ -z "$out" ]'
out=$(cap c2 "$root/read.jsonl")
check "capture is silent on a short read-only session" '[ -z "$out" ]'
out=$(cap c3 "$root/wrote.jsonl")
check "capture is silent after add_memory" '[ -z "$out" ]'
out=$(cap c4 "$root/edit.jsonl" true)
check "capture is silent on its own continuation" '[ -z "$out" ]'

# --- auto-format: untrusted prettier never runs -------------------------------------
mk_prettier() { # mk_prettier <repo> : fake prettier that leaves a marker
  mkdir -p "$1/node_modules/.bin"
  printf '#!/bin/sh\ntouch "%s/RAN"\n' "$1" >"$1/node_modules/.bin/prettier"
  chmod +x "$1/node_modules/.bin/prettier"
}
git init -q "$root/trusted" && mk_prettier "$root/trusted" && echo x >"$root/trusted/a.md"
git init -q "$root/hostile" && mk_prettier "$root/hostile" && echo x >"$root/hostile/a.md"
git -C "$root/hostile" add -f node_modules a.md
mkdir -p "$root/norepo" && mk_prettier "$root/norepo" && echo x >"$root/norepo/a.md"
fmt() { run_hook "$here/auto-format.sh" "{\"cwd\": \"$1\", \"tool_input\": {\"file_path\": \"$2\"}}" >/dev/null 2>&1; }
fmt "$root" "$root/trusted/a.md"
check "auto-format runs the project's own prettier" '[ -f "$root/trusted/RAN" ]'
fmt "$root" "$root/hostile/a.md"
check "auto-format skips a repo that commits node_modules" '[ ! -f "$root/hostile/RAN" ]'
fmt "$root" "$root/norepo/a.md"
check "auto-format skips a directory outside git" '[ ! -f "$root/norepo/RAN" ]'
rm -f "$root/trusted/RAN"
fmt "$root/trusted" "a.md"
check "auto-format resolves a relative path (no hang)" '[ -f "$root/trusted/RAN" ]'

# --- statusline ------------------------------------------------------------------
git init -q -b main "$root/proj" && mkdir -p "$root/proj/sub" && echo x >"$root/proj/f" && git -C "$root/proj" add f && git -C "$root/proj" commit -qm init
sl() { run_hook "$statusline" "$1"; }
index_before=$(stat -f %m "$root/proj/.git/index" 2>/dev/null || stat -c %Y "$root/proj/.git/index")
sleep 1
touch "$root/proj/f"
out=$(sl "{\"cwd\": \"$root/proj/sub\", \"workspace\": {\"project_dir\": \"$root/proj\"}, \"model\": {\"display_name\": \"Opus\"}, \"context_window\": {\"used_percentage\": 42}}")
index_after=$(stat -f %m "$root/proj/.git/index" 2>/dev/null || stat -c %Y "$root/proj/.git/index")
check "statusline shows project-relative dir and branch" 'printf "%s" "$out" | grep -q "proj/sub (main"'
check "statusline shows context percent" 'printf "%s" "$out" | grep -q "ctx 42%"'
check "statusline does not rewrite .git/index" '[ "$index_before" = "$index_after" ]'
out=$(sl "{\"cwd\": \"/usr\", \"workspace\": {\"project_dir\": \"$root/proj\"}}")
check "statusline shows a plain dir outside the project" 'printf "%s" "$out" | grep -q "^usr"'
out=$(sl "{\"cwd\": \"$root\", \"model\": {\"display_name\": [\"x\", \"touch\", \"$root/PWNED\"]}}")
check "statusline does not execute array values" '[ ! -e "$root/PWNED" ]'

if ((failures)); then
  echo "$failures check(s) failed"
  exit 1
fi
echo "all checks passed"
