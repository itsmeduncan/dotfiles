#!/bin/sh
# PostToolUse hook: auto-format files after Edit/Write
# Reads tool output JSON from stdin to extract the file path

set -e

# Parse the file path from the tool input JSON
FILE_PATH=$(cat | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

case "$FILE_PATH" in
  *.py)
    ruff format --quiet "$FILE_PATH" 2>/dev/null || true
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    npx --yes prettier --write --log-level silent "$FILE_PATH" 2>/dev/null || true
    ;;
  *.swift)
    swiftformat --quiet "$FILE_PATH" 2>/dev/null || true
    ;;
  *.kt|*.kts)
    ktlint --format "$FILE_PATH" 2>/dev/null || true
    ;;
esac
