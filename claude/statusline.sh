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

# --- Git branch + working-tree state (read-only; never touches the index lock) ---
branch=$(git -C "${cwd:-.}" symbolic-ref --short HEAD 2>/dev/null)
dirty=""
ahead_behind=""
if [ -n "$branch" ]; then
  # Dirty marker if the working tree has any staged/unstaged/untracked changes
  [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ] && dirty="✱"
  # Ahead/behind vs upstream, if one is configured
  counts=$(git -C "$cwd" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
  if [ -n "$counts" ]; then
    behind=${counts%%[[:space:]]*}
    ahead=${counts##*[[:space:]]}
    [ "$ahead" -gt 0 ] 2>/dev/null && ahead_behind="${ahead_behind}↑${ahead}"
    [ "$behind" -gt 0 ] 2>/dev/null && ahead_behind="${ahead_behind}↓${behind}"
  fi
fi

# --- Model (short form) ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- Context window usage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Rate limits (Claude.ai subscribers only) ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- ANSI colors ---
RESET='\033[0m'
DIM='\033[2m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'

# --- Build output ---
# Directory + branch (+ dirty marker + ahead/behind)
if [ -n "$branch" ]; then
  git_state="${branch}"
  [ -n "$dirty" ] && git_state="${git_state}${dirty}"
  [ -n "$ahead_behind" ] && git_state="${git_state} ${ahead_behind}"
  location="${dir_part} (${git_state})"
else
  location="${dir_part}"
fi

# Model
model_part=""
[ -n "$model" ] && model_part=" ${DIM}|${RESET} ${model}"

# Context — color-graded as the window fills (green < 50, yellow < 80, red ≥ 80)
ctx_part=""
if [ -n "$used_pct" ]; then
  ctx_fmt=$(printf "%.0f" "$used_pct")
  if [ "$ctx_fmt" -ge 80 ] 2>/dev/null; then
    ctx_color="$RED"
  elif [ "$ctx_fmt" -ge 50 ] 2>/dev/null; then
    ctx_color="$YELLOW"
  else
    ctx_color="$GREEN"
  fi
  ctx_part=" ${DIM}|${RESET} ${ctx_color}ctx ${ctx_fmt}%${RESET}"
fi

# Rate limits
rate_part=""
if [ -n "$five_pct" ] || [ -n "$week_pct" ]; then
  rate_part=" ${DIM}|${RESET}"
  [ -n "$five_pct" ] && rate_part="${rate_part} 5h:$(printf '%.0f' "$five_pct")%"
  [ -n "$week_pct" ] && rate_part="${rate_part} 7d:$(printf '%.0f' "$week_pct")%"
fi

printf "%b%b%b%b" "$location" "$model_part" "$ctx_part" "$rate_part"
