#!/bin/sh
# Claude Code status line script
# Receives JSON on stdin; outputs a single status line.

input=$(cat)

# --- Working directory (project-relative if inside a project) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
if [ -n "$project_dir" ] && [ "$cwd" != "$project_dir" ]; then
  # Show path relative to project root, prefixed with the project dir name
  proj_name=$(basename "$project_dir")
  rel="${cwd#$project_dir}"
  dir_part="${proj_name}${rel}"
else
  dir_part=$(basename "${cwd:-$(pwd)}")
fi

# --- Git branch (optional, skip lock to avoid interfering with other git ops) ---
branch=$(git -C "${cwd:-.}" symbolic-ref --short HEAD 2>/dev/null)

# --- Model (short form) ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- Context window usage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Rate limits (Claude.ai subscribers only) ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- Build output ---
# Directory + branch
if [ -n "$branch" ]; then
  location="${dir_part} (${branch})"
else
  location="${dir_part}"
fi

# Model
model_part=""
[ -n "$model" ] && model_part=" | ${model}"

# Context
ctx_part=""
if [ -n "$used_pct" ]; then
  ctx_fmt=$(printf "%.0f" "$used_pct")
  ctx_part=" | ctx ${ctx_fmt}%"
fi

# Rate limits
rate_part=""
if [ -n "$five_pct" ] || [ -n "$week_pct" ]; then
  rate_part=" |"
  [ -n "$five_pct" ] && rate_part="${rate_part} 5h:$(printf '%.0f' "$five_pct")%"
  [ -n "$week_pct" ] && rate_part="${rate_part} 7d:$(printf '%.0f' "$week_pct")%"
fi

printf "%s%s%s%s" "$location" "$model_part" "$ctx_part" "$rate_part"
