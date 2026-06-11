#!/bin/bash
# Shared helpers for install.sh modules.
# Sourced by every lib/*.sh — never executed directly.
#
# Provides:
#   log/warn/ok/err   — structured stderr logging
#   would             — print a "[DRY]" preview line and return 0
#   run               — execute a command unless DRY_RUN=1
#   link              — idempotent symlink with parent dir creation
#   check             — append to CHECK_REPORT array (for --check mode)
#
# Globals consumed:
#   DRY_RUN     — if "1", mutating commands are previewed not executed
#   CHECK_MODE  — if "1", install runs as a read-only audit
#   DOTFILES_DIR — repo root (exported by install.sh)

# Colors only when stderr is a TTY.
if [ -t 2 ]; then
  _C_DIM=$'\033[2m'; _C_RED=$'\033[31m'; _C_YEL=$'\033[33m'
  _C_GRN=$'\033[32m'; _C_CYN=$'\033[36m'; _C_RST=$'\033[0m'
else
  _C_DIM=""; _C_RED=""; _C_YEL=""; _C_GRN=""; _C_CYN=""; _C_RST=""
fi

log()  { printf "%s[INFO]%s %s\n" "$_C_CYN" "$_C_RST" "$*" >&2; }
ok()   { printf "%s[ OK ]%s %s\n" "$_C_GRN" "$_C_RST" "$*" >&2; }
warn() { printf "%s[WARN]%s %s\n" "$_C_YEL" "$_C_RST" "$*" >&2; }
err()  { printf "%s[ERR ]%s %s\n" "$_C_RED" "$_C_RST" "$*" >&2; }

would() {
  printf "%s[DRY ]%s would: %s\n" "$_C_DIM" "$_C_RST" "$*" >&2
}

# run "<description>" cmd args...
# Executes cmd unless DRY_RUN=1.
run() {
  local desc="$1"; shift
  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "$desc"
    return 0
  fi
  "$@"
}

# link <src> <dst>
# Idempotent symlink. Creates parent dir of dst. Honors DRY_RUN and CHECK_MODE.
link() {
  local src="$1" dst="$2"
  if [ "${CHECK_MODE:-0}" = "1" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      ok "link OK: $dst → $src"
    elif [ -e "$dst" ]; then
      warn "link DRIFT: $dst exists but is not a symlink to $src"
    else
      warn "link MISSING: $dst → $src"
    fi
    return 0
  fi
  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "ln -sfn $src $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

# Detect macOS major version (e.g. "26" for Tahoe). Returns empty string off-mac.
macos_major() {
  if [ "$(uname)" = "Darwin" ]; then
    sw_vers -productVersion | cut -d. -f1
  fi
}
