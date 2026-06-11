#!/bin/bash
# macOS productivity defaults + firewall.
# Each `set_default` is a diff-before-write: no `defaults write` unless the
# stored value differs. Finder/Dock are only restarted when something actually
# changed. macOS-version-aware so keys that don't exist on the current major
# version are skipped cleanly.
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

_DEFAULTS_CHANGED=false

# set_default <domain> <key> <type> <value> [min_macos_major]
# Writes the default only if it differs. If min_macos_major is supplied and
# the current macOS major is lower, the write is skipped (with a debug note).
set_default() {
  local domain="$1" key="$2" type="$3" value="$4" min_major="${5:-}"
  local current major
  major="$(macos_major)"
  if [ -n "$min_major" ] && [ -n "$major" ] && [ "$major" -lt "$min_major" ]; then
    return 0
  fi
  current=$(defaults read "$domain" "$key" 2>/dev/null) || current=""
  if [ "$current" = "$value" ]; then
    return 0
  fi
  if [ "${CHECK_MODE:-0}" = "1" ]; then
    warn "macOS default drift: $domain $key (current=$current, want=$value)"
    return 0
  fi
  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "defaults write $domain $key $type $value"
    return 0
  fi
  defaults write "$domain" "$key" "$type" "$value"
  _DEFAULTS_CHANGED=true
}

macos_run() {
  if [ "$(uname)" != "Darwin" ]; then
    warn "Not on macOS — skipping defaults + firewall"
    return 0
  fi

  set_default NSGlobalDomain AppleShowAllExtensions -bool true
  set_default NSGlobalDomain KeyRepeat -int 2
  set_default NSGlobalDomain InitialKeyRepeat -int 15
  set_default com.apple.finder AppleShowAllFiles -bool true
  set_default com.apple.finder ShowPathbar -bool true
  set_default com.apple.finder ShowStatusBar -bool true
  set_default com.apple.finder _FXShowPosixPathInTitle -bool true
  set_default com.apple.finder FXPreferredViewStyle -string Nlsv
  set_default com.apple.finder _FXSortFoldersFirst -bool true
  set_default com.apple.dock autohide -bool true
  set_default com.apple.dock tilesize -int 48
  set_default com.apple.dock show-recents -bool false
  set_default com.apple.NSScrollAnimationEnabled -bool false

  # Smart quotes / dashes
  set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Expand save / print panels
  set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  set_default NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

  # Trackpad tap to click
  set_default com.apple.AppleMultitouchTrackpad Clicking -bool true
  set_default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

  macos_firewall

  if [ "$_DEFAULTS_CHANGED" = true ] && [ "${DRY_RUN:-0}" != "1" ] \
       && [ "${CHECK_MODE:-0}" != "1" ]; then
    # This closes all open Finder windows.
    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true
  fi
}

macos_firewall() {
  if ! /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null \
       | grep -q "enabled"; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then
      warn "macOS firewall is disabled"
      return 0
    fi
    if [ "${DRY_RUN:-0}" = "1" ]; then
      would "sudo enable macOS application firewall"
      return 0
    fi
    log "Enabling macOS application firewall (requires sudo)..."
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on \
      2>/dev/null || warn "firewall enable failed"
  fi
}
