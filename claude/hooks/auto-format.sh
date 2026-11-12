#!/bin/sh
# PostToolUse hook: auto-format files after Edit/Write
# Reads tool output JSON from stdin to extract the file path

set -e

# Parse the file path from the tool input JSON
FILE_PATH=$(cat | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Print the nearest executable $1 found in $2 or a parent directory.
find_up() {
  dir=$2
  while [ -n "$dir" ]; do
    if [ -x "$dir/$1" ]; then
      echo "$dir/$1"
      return
    fi
    dir=${dir%/*}
  done
}

# Use the project's own prettier, and only in projects that install it.
# `npx --yes prettier` cost ~0.6 s per edit, could download a package, and
# reformatted files in repos that do not use prettier.
format_prettier() {
  prettier=$(find_up node_modules/.bin/prettier "$(dirname "$FILE_PATH")")
  [ -n "$prettier" ] || return 0
  "$prettier" --write --log-level silent "$FILE_PATH" 2>/dev/null || true
}

case "$FILE_PATH" in
  *.py)
    ruff format --quiet "$FILE_PATH" 2>/dev/null || true
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    format_prettier
    ;;
  *.swift)
    swiftformat --quiet "$FILE_PATH" 2>/dev/null || true
    ;;
  *.kt|*.kts)
    ktlint --format "$FILE_PATH" 2>/dev/null || true
    ;;
esac
