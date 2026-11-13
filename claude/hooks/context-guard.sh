#!/bin/sh
# UserPromptSubmit hook: tell the model when the session's context is so large
# that every turn re-reads hundreds of thousands of tokens. One month of
# transcripts averaged 345k context per call; 41 of 84 sessions compacted
# (167 times) and one ran 181 hours.
#
# Fires once per 100k-token step above CONTEXT_GUARD_TOKENS (default 400000),
# and only adds context for the model: it never blocks the prompt.
#
# POSIX sh: Claude Code may run hooks through dash.

set -u

# Read exactly one JSON value from stdin, never to end-of-file: Claude Code
# sometimes keeps a hook's stdin open, and a hook that waits for EOF hangs
# until its timeout and then fails open.
input=$(jq -c -n input 2>/dev/null) || exit 0
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null) || exit 0
session=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null) || exit 0
[ -n "$transcript" ] && [ -f "$transcript" ] && [ -n "$session" ] || exit 0

limit=${CONTEXT_GUARD_TOKENS:-400000}

# Context of the last model call = input + cache read + cache write tokens.
# Only the tail is read, so a 500 MB transcript costs the same as a small one.
tokens=$(tail -c 2000000 "$transcript" 2>/dev/null \
  | grep '"usage"' | tail -1 \
  | jq -r '.message.usage // .usage // {} | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)' 2>/dev/null)
case "$tokens" in '' | *[!0-9]*) exit 0 ;; esac
[ "$tokens" -ge "$limit" ] || exit 0

# Warn once per 100k step, not on every prompt.
state="${TMPDIR:-/tmp}/claude-context-guard"
mkdir -p "$state" 2>/dev/null || exit 0
step=$((tokens / 100000))
marker="$state/$(printf '%s' "$session" | tr -cd 'A-Za-z0-9_-')"
[ "$(cat "$marker" 2>/dev/null)" = "$step" ] && exit 0
printf '%s\n' "$step" >"$marker"

k=$((tokens / 1000))
jq -n --arg k "$k" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: ("context-guard: this session is at \($k)k tokens of context, and every turn re-reads all of it. Finish the current task, record a handoff where the next session will find it (task_append on the scriptorium task, or the PR/issue), and tell dg in one line that a fresh session (/clear) is now cheaper. Do not start new unrelated work in this session.")
  }
}'
