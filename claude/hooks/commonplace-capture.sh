#!/usr/bin/env bash
# commonplace-capture.sh — Claude Code Stop hook that nudges a memory-capture
# pass at the end of a substantive session, so the WRITE step of the memory
# protocol stops being discretionary.
#
# Fires at most ONCE per session and only when:
#   - this isn't the continuation we ourselves triggered (no loops), AND
#   - add_memory was NOT already called this session, AND
#   - the session did SUBSTANTIAL work — it mutated a file (Edit/Write/
#     NotebookEdit) or ran a long tool-heavy session (>= COMMONPLACE_CAPTURE_
#     MIN_TOOLS tool_uses, default 12). Read-only lookups and quick chats are
#     skipped so the hook stays quiet on trivial sessions.
# Otherwise it exits silently (0) and Claude stops normally.
#
# Speed: the hook runs on every Stop. Grepping the whole transcript (up to
# 500 MB) timed out at 15 s 59 times in one month, and a timeout skips the
# nudge. So it keeps per-session state under $TMPDIR and scans only the bytes
# appended since the last Stop. A session first seen when already large is
# scanned from its last 5 MB only.
#
# Registered under hooks.Stop in claude/settings.json. Requires jq.
#
# POSIX sh only (no `pipefail`): Claude Code runs the hook command through the
# system shell, which is dash on most Linux hosts.
set -eu
# Read exactly one JSON value from stdin, never to end-of-file: Claude Code
# sometimes keeps a hook's stdin open, and a hook that waits for EOF hangs
# until its timeout and then fails open.
input=$(jq -c -n input 2>/dev/null) || exit 0

# Don't re-fire on our own continuation → prevents infinite Stop loops.
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
{ [ -z "$transcript" ] || [ ! -f "$transcript" ]; } && exit 0
session=$(printf '%s' "$input" | jq -r '.session_id // empty' | tr -cd 'A-Za-z0-9_-')
[ -n "$session" ] || session=$(printf '%s' "$transcript" | cksum | cut -d' ' -f1)

state_dir="${TMPDIR:-/tmp}/commonplace-capture"
mkdir -p "$state_dir"
st="$state_dir/$session"
# Already wrote to memory, or already nudged once: stay quiet for the session.
{ [ -f "$st.wrote" ] || [ -f "$st.nudged" ]; } && exit 0

size=$(wc -c <"$transcript" | tr -d ' ')
offset=$(cat "$st.offset" 2>/dev/null || echo 0)
[ "$offset" -le "$size" ] || offset=0 # transcript replaced: start over
window=5000000
[ "$offset" -eq 0 ] && [ "$size" -gt "$window" ] && offset=$((size - window))

chunk=$(mktemp "$state_dir/chunk.XXXXXX")
trap 'rm -f "$chunk"' EXIT
tail -c +"$((offset + 1))" "$transcript" >"$chunk"
printf '%s\n' "$size" >"$st.offset"

# Match add_memory ONLY. search_nodes/search_memory_facts are the protocol's
# read-first step and must not suppress the write nudge. MCP tools are
# namespaced (mcp__commonplace-personal__add_memory); spacing varies.
if grep -qE '"name":[[:space:]]*"(mcp__[a-zA-Z0-9_-]+__)?add_memory"' "$chunk"; then
  : >"$st.wrote"
  exit 0
fi

count() { grep -cE "$1" "$chunk" || true; }
mutated=$(($(cat "$st.mutated" 2>/dev/null || echo 0) + $(count '"name":[[:space:]]*"(Edit|Write|NotebookEdit)"')))
tool_uses=$(($(cat "$st.tools" 2>/dev/null || echo 0) + $(count '"type":[[:space:]]*"tool_use"')))
printf '%s\n' "$mutated" >"$st.mutated"
printf '%s\n' "$tool_uses" >"$st.tools"

min_tools=${COMMONPLACE_CAPTURE_MIN_TOOLS:-12}
[ "$mutated" -eq 0 ] && [ "$tool_uses" -lt "$min_tools" ] && exit 0

: >"$st.nudged"
# Drop state older than a week so $TMPDIR does not grow without bound.
find "$state_dir" -type f -mtime +7 -delete 2>/dev/null || true

jq -n '{
  decision: "block",
  reason: "commonplace capture: silently search_nodes to dedupe, then add_memory(agent_id=\"claude-code\") for durable facts only — decisions, preferences, project/people. Personal tier unless confidential (then client). Do NOT narrate the pass: emit ONE terse line and nothing else — `memory: saved N — <2-4 word gist>`, or `memory: nothing durable`."
}'
