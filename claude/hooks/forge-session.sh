#!/bin/sh
# SessionStart hook: in a repo hosted on a self-hosted forge, put that forge's
# workspace call shapes in front of the model at session start. In one month,
# only 21 of 54 sessions that used the workspace tools read its protocol first,
# and ~800 calls were refused for argument shapes. Other repos get nothing.
#
# The forge names live in a machine-local, untracked file, so this public repo
# names no hosts or projects:
#   ${DOTFILES_LOCAL:-~/.config/dotfiles-local}/claude/forge-session.json
#   {"origins": ["*forge-host*", ...], "context": "<text for the model>"}
# An origin URL that matches any glob in "origins" gets "context". No file, no
# output.
#
# POSIX sh: Claude Code may run hooks through dash.

set -u

config="${DOTFILES_LOCAL:-$HOME/.config/dotfiles-local}/claude/forge-session.json"

# Read exactly one JSON value from stdin, never to end-of-file: Claude Code
# sometimes keeps a hook's stdin open, and a hook that waits for EOF hangs
# until its timeout and then fails open.
cwd=$(jq -n -r 'input | .cwd // empty' 2>/dev/null) || exit 0
[ -r "$config" ] || exit 0
[ -n "$cwd" ] || cwd=$PWD
origin=$(git -C "$cwd" remote get-url origin 2>/dev/null) || exit 0

origin_matches() {
  jq -r '.origins[]? // empty' "$config" 2>/dev/null | while IFS= read -r pattern; do
    # Unquoted on purpose: the pattern is a glob.
    # shellcheck disable=SC2254
    case "$origin" in $pattern) echo match && break ;; esac
  done
}
[ -n "$(origin_matches)" ] || exit 0

jq '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("forge-session: " + .context)
  }
}' "$config"
