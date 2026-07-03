#!/usr/bin/env bash
# commonplace-capture.sh — Stop hook that nudges a commonplace memory-capture
# pass at the end of a substantive session.
#
# Fires at most ONCE per session and only when:
#   - this isn't the continuation we ourselves triggered (no loops), AND
#   - add_memory was NOT already called this session, AND
#   - the session actually did work (>=1 tool_use).
# Otherwise it exits silently (0) and Claude stops normally.
set -euo pipefail
input=$(cat)

# Don't re-fire on our own continuation → prevents infinite Stop loops.
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
{ [ -z "$transcript" ] || [ ! -f "$transcript" ]; } && exit 0

# Already captured this session? Nothing to nudge. MCP tools are recorded with a
# namespaced name, e.g. "mcp__commonplace-personal__add_memory" — match that too.
grep -qE '"name":"(mcp__[a-zA-Z0-9_-]+__)?add_memory"' "$transcript" 2>/dev/null && exit 0

# Only bother if the session actually used tools (skip trivial chats).
grep -q '"type":"tool_use"' "$transcript" 2>/dev/null || exit 0

jq -n '{
  decision: "block",
  reason: "Before ending: run a commonplace memory-capture pass. First search_nodes to avoid duplicates, then add_memory (agent_id=\"claude-code\") for any DURABLE facts from this session — decisions+rationale, stable preferences, project/people/org facts, requirements. Use the personal tier for non-confidential data; the client tier only for NDA/confidential. If nothing durable emerged, say so briefly and stop."
}'
