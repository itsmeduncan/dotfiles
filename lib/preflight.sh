#!/bin/bash
# Preflight: things that must exist before anything else can run.
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

preflight_run() {
  if ! xcode-select -p &>/dev/null; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then
      warn "Xcode CLI tools not installed"
      return 0
    fi
    log "Installing Xcode Command Line Tools..."
    run "xcode-select --install" xcode-select --install
    log "Press enter after Xcode tools finish installing."
    [ "${DRY_RUN:-0}" = "1" ] || read -r
  else
    ok "Xcode CLI tools present"
  fi
}
