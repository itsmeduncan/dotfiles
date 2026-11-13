#!/bin/sh
# SessionStart hook: in a repo hosted on the scriptorium forge (whelk,
# scriptorium, inkhold and their worktrees), put the workspace call shapes in
# front of the model at session start. In one month, only 21 of 54 sessions
# that used scriptorium tools read the protocol first, and ~800 calls were
# refused for argument shapes. Other repos (GitHub flow) get nothing.
#
# POSIX sh: Claude Code may run hooks through dash.

set -u

# Read exactly one JSON value from stdin, never to end-of-file: Claude Code
# sometimes keeps a hook's stdin open, and a hook that waits for EOF hangs
# until its timeout and then fails open.
cwd=$(jq -n -r 'input | .cwd // empty' 2>/dev/null) || exit 0
[ -n "$cwd" ] || cwd=$PWD
origin=$(git -C "$cwd" remote get-url origin 2>/dev/null) || exit 0
case "$origin" in
  *scriptorium* | *whelk-forge*) ;;
  *) exit 0 ;;
esac

jq -n '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: "scriptorium-session: this repo is hosted on scriptorium, so its tasks and changes live there (not GitHub). Before your first workspace call, run mcp__scriptorium__doc_read({\"slug\": \"scriptorium-protocol\"}) and follow it. Call shapes, from ~800 refused calls in one month:\n- The tools are deferred: load each schema with ToolSearch (select:mcp__scriptorium__<tool>,..., batched) before its first call.\n- Every mutation needs idempotency_key: a fresh UUID per intended change, reused only to retry that change.\n- List filters such as status and priority take arrays, never a string: task_query({\"status\": [\"ready\"]}).\n- Free text goes in text (task_append), question (task_ask) and why (task_block), not body, note or reason.\n- Pages and projects take slug (doc_read({\"slug\": ...}), never path); changes take id.\n- change_open requires repo, project, branch and title; task links go in closes/relates, never in the body.\n- Call tools by their listed names (decision_search, person_list, release_promotion_list), not legacy aliases."
  }
}'
