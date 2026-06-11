#!/bin/bash
# install.sh — orchestrator for dotfiles bootstrap.
#
# Each phase is a module under lib/ that exposes a <name>_run function.
# Modules share helpers via lib/_common.sh (log/warn/ok/link/run/would).
#
# Flags:
#   --dry-run   Print every mutating action as "[DRY] would: ..." without executing.
#   --check     Audit mode: report drift (missing symlinks, mise/brew/macos state)
#               without making any changes.
#   --skip=<phase>[,<phase>...]
#               Skip one or more phases. Phase names: preflight, brew, symlinks,
#               mise, agents, runtimes, android, macos, ssh.
#   --only=<phase>[,<phase>...]
#               Inverse of --skip: run only these phases.
#   --snapshot  Write bootstrap-state.snapshot recording current versions of
#               every brew/mise tool, submodule, and plugin.
#   --help      Show this help.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
export DOTFILES_DIR

DRY_RUN=0
CHECK_MODE=0
SKIP_PHASES=""
ONLY_PHASES=""
SNAPSHOT_ONLY=0

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --check) CHECK_MODE=1 ;;
    --skip=*) SKIP_PHASES="${1#--skip=}" ;;
    --only=*) ONLY_PHASES="${1#--only=}" ;;
    --snapshot) SNAPSHOT_ONLY=1 ;;
    --help | -h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown flag: $1" >&2
      usage
      exit 64
      ;;
  esac
  shift
done

export DRY_RUN CHECK_MODE

# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

# --snapshot is a standalone mode: write (or, with --check, verify) the
# bootstrap-state.snapshot file and exit. Does not run install phases.
if [ "$SNAPSHOT_ONLY" = "1" ]; then
  # shellcheck source=lib/snapshot.sh
  . "$DOTFILES_DIR/lib/snapshot.sh"
  if [ "$CHECK_MODE" = "1" ]; then
    SNAPSHOT_MODE="check"
  else
    SNAPSHOT_MODE="write"
  fi
  export SNAPSHOT_MODE
  snapshot_run
  exit $?
fi

# Phase ordering matters:
#   preflight → brew (provides mise) → symlinks (cheap, no deps) → mise →
#   agents → runtimes → android → macos → ssh
_PHASES=(preflight brew symlinks mise agents runtimes android macos ssh)

_should_run() {
  local phase="$1"
  if [ -n "$ONLY_PHASES" ]; then
    case ",$ONLY_PHASES," in
      *",$phase,"*) return 0 ;;
      *) return 1 ;;
    esac
  fi
  case ",$SKIP_PHASES," in
    *",$phase,"*) return 1 ;;
  esac
  return 0
}

if [ "$DRY_RUN" = "1" ]; then
  log "DRY RUN — no changes will be made"
fi
if [ "$CHECK_MODE" = "1" ]; then
  log "CHECK MODE — auditing without changes"
fi

for phase in "${_PHASES[@]}"; do
  if ! _should_run "$phase"; then
    log "skipping phase: $phase"
    continue
  fi
  # shellcheck source=/dev/null
  . "$DOTFILES_DIR/lib/${phase}.sh"
  log "▸ phase: $phase"
  "${phase}_run"
done

ok "install.sh complete"
