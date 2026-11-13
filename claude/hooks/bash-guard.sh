#!/bin/sh
# PreToolUse hook (matcher: Bash): refuse the commands that CLAUDE.md forbids
# and that transcripts show agents running anyway. Prose rules were broken
# 55 times (pkill/killall by name) and 20 times (--no-verify) in one month.
#
# Exit 2 blocks the call; Claude Code shows stderr to the model, so every
# message says what to do instead. Anything else exits 0.
#
# POSIX sh: Claude Code may run hooks through dash.

set -u

# Read exactly one JSON value from stdin, never to end-of-file: Claude Code
# sometimes keeps a hook's stdin open, and a hook that waits for EOF hangs
# until its timeout and then fails open.
cmd=$(jq -n -r 'input | .tool_input.command // empty' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

block() {
  printf 'bash-guard: %s\n' "$1" >&2
  exit 2
}

matches() { printf '%s\n' "$cmd" | grep -qE -- "$1"; }

# A command word at the start of a line or after ; & | ( or a sudo/exec prefix.
start='(^|[;&|(]|&&|\|\|)[[:space:]]*((sudo|exec|command|nohup)[[:space:]]+)?'

if matches "${start}(pkill|killall)([[:space:]]|$)"; then
  block "kill by name can stop processes dg runs. Find the PID of a process you started (\$!, pgrep -f with an exact pattern, lsof -i :PORT) and kill that PID."
fi

if matches "git[[:space:]].*--no-verify" || matches "git[[:space:]].*-c[[:space:]]*core\.hooksPath="; then
  block "skipping git hooks bypasses the repo's precheck. Fix what the hook reports, or ask dg with AskUserQuestion."
fi

# Force push (any form) that names main or master.
if matches "git[[:space:]].*push" \
  && matches "(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+[^[:space:]]+)" \
  && matches "([[:space:]:/+]|^)(main|master)([[:space:]]|$)"; then
  block "force push to main/master rewrites shared history. Push a branch and open a change or PR instead."
fi

exit 0
