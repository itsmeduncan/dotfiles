#!/bin/sh
# PostToolUse hook: auto-format files after Edit/Write.
# Reads the tool call JSON from stdin to get the file path.
#
# Prettier runs only from the project's own node_modules, and only when the
# project is a git repo that does NOT commit node_modules: a cloned repo that
# ships its own node_modules/.bin/prettier would otherwise run its code on
# every edit.

# Read exactly one JSON value from stdin, never to end-of-file: Claude Code
# sometimes keeps a hook's stdin open, and a hook that waits for EOF hangs
# until its timeout and then fails open.
input=$(jq -c -n input 2>/dev/null) || exit 0
FILE_PATH=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
[ -n "$FILE_PATH" ] || exit 0

# Resolve a relative path against the session's cwd.
case "$FILE_PATH" in
  /*) ;;
  *)
    base=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
    FILE_PATH="${base:-$PWD}/$FILE_PATH"
    ;;
esac
[ -f "$FILE_PATH" ] || exit 0

# The project's own prettier: node_modules/.bin/prettier between the file's
# directory and the git top-level, in a repo that does not track node_modules.
project_prettier() {
  dir=$(cd "$(dirname "$FILE_PATH")" 2>/dev/null && pwd -P) || return 0
  top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || return 0
  [ -z "$(git -C "$top" ls-files -- node_modules 2>/dev/null | head -1)" ] || return 0
  while :; do
    if [ -x "$dir/node_modules/.bin/prettier" ]; then
      echo "$dir/node_modules/.bin/prettier"
      return 0
    fi
    [ "$dir" = "$top" ] && return 0
    parent=${dir%/*}
    [ -n "$parent" ] && [ "$parent" != "$dir" ] || return 0
    dir=$parent
  done
}

format_prettier() {
  prettier=$(project_prettier)
  [ -n "$prettier" ] || return 0
  "$prettier" --write --log-level silent "$FILE_PATH" 2>/dev/null || true
}

case "$FILE_PATH" in
  *.py)
    ruff format --quiet "$FILE_PATH" 2>/dev/null || true
    ;;
  *.ts | *.tsx | *.js | *.jsx | *.json | *.css | *.md)
    format_prettier
    ;;
  *.swift)
    swiftformat --quiet "$FILE_PATH" 2>/dev/null || true
    ;;
  *.kt | *.kts)
    ktlint --format "$FILE_PATH" 2>/dev/null || true
    ;;
esac
exit 0
