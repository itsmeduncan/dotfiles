#!/bin/sh
# Claude Code status line script
# Receives JSON on stdin; outputs a single status line.

# Never take git's optional locks: `git status` would otherwise rewrite
# .git/index on each refresh and collide with an agent's `git commit`
# ("index.lock exists").
export GIT_OPTIONAL_LOCKS=0

# Parse every field in one jq call (this runs on each refresh; six jq forks
# cost ~30 ms). @sh quotes each value so eval is safe; `s` turns anything that
# is not a string or number into "" so an odd field cannot inject words or
# blank the others.
cwd='' project_dir='' model='' used_pct='' five_pct='' week_pct=''
# `jq -n input` reads one JSON value and exits, even if stdin stays open.
eval "$(jq -n -r 'def s: if type == "string" or type == "number" then tostring else "" end;
  input | @sh "
  cwd=\((.workspace.current_dir // .cwd // "") | s)
  project_dir=\((.workspace.project_dir // "") | s)
  model=\((.model.display_name // "") | s)
  used_pct=\((.context_window.used_percentage // "") | s)
  five_pct=\((.rate_limits.five_hour.used_percentage // "") | s)
  week_pct=\((.rate_limits.seven_day.used_percentage // "") | s)
"' 2>/dev/null)"

# --- Working directory (project-relative only when inside the project) ---
dir_part=$(basename "${cwd:-$(pwd)}")
if [ -n "$project_dir" ]; then
  case "$cwd" in
    "$project_dir"/*) dir_part="$(basename "$project_dir")${cwd#"$project_dir"}" ;;
  esac
fi

# --- Git branch + working-tree state (read-only; no optional locks) ---
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
  ctx_fmt=$(printf "%.0f" "$used_pct" 2>/dev/null)
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
  [ -n "$five_pct" ] && rate_part="${rate_part} 5h:$(printf '%.0f' "$five_pct" 2>/dev/null)%"
  [ -n "$week_pct" ] && rate_part="${rate_part} 7d:$(printf '%.0f' "$week_pct" 2>/dev/null)%"
fi

printf "%b%b%b%b" "$location" "$model_part" "$ctx_part" "$rate_part"
