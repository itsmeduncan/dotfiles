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
  local current major canonical
  major="$(macos_major)"
  if [ -n "$min_major" ] && [ -n "$major" ] && [ "$major" -lt "$min_major" ]; then
    return 0
  fi
  current=$(defaults read "$domain" "$key" 2>/dev/null) || current=""

  # `defaults read` returns canonical "1"/"0" for bools and unquoted strings.
  # Normalize the desired value to match before comparing, so we don't write
  # on every run when nothing actually changed.
  canonical="$value"
  case "$type" in
    -bool)
      case "$value" in
        true | TRUE | yes | YES | 1) canonical=1 ;;
        false | FALSE | no | NO | 0) canonical=0 ;;
      esac
      ;;
  esac

  if [ "$current" = "$canonical" ]; then
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
  set_default NSGlobalDomain NSScrollAnimationEnabled -bool false

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
  macos_markdown_handler

  if [ "$_DEFAULTS_CHANGED" = true ] && [ "${DRY_RUN:-0}" != "1" ] \
    && [ "${CHECK_MODE:-0}" != "1" ]; then
    # This closes all open Finder windows.
    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true
  fi
}

# Make nvim (in a new Ghostty window) the default macOS app for markdown files.
# Compiles macos/open-in-neovim.applescript to a wrapper .app, stamps it with a
# stable bundle id, and points every markdown UTI + extension at it via duti.
# Idempotent: the app is only recompiled when the source changes; duti -s is a
# no-op when the association already matches.
macos_markdown_handler() {
  local src="$DOTFILES_DIR/macos/open-in-neovim.applescript"
  local app="$HOME/Applications/Open in Neovim.app"
  local bundle_id="com.itsmeduncan.open-in-neovim"
  local lsregister="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
  # net.daringfireball.markdown is the UTI macOS registers for .md; the bare
  # public.markdown UTI isn't in the system hierarchy, so we key off extensions.
  local utis="net.daringfireball.markdown"
  local exts="md markdown mdown mkd markdn"

  if ! command -v duti >/dev/null 2>&1; then
    warn "duti not installed — skipping markdown default-app registration (run the brew phase)"
    return 0
  fi

  if [ "${CHECK_MODE:-0}" = "1" ]; then
    local cur
    cur=$(duti -x md 2>/dev/null | tail -1)
    if [ "$cur" = "$bundle_id" ]; then
      ok "markdown handler OK: .md → $bundle_id"
    else
      warn "markdown handler DRIFT: .md → ${cur:-none} (want $bundle_id)"
    fi
    return 0
  fi

  # Recompile the wrapper app only when it's missing or the source changed.
  local rebuilt=false
  if [ ! -d "$app" ] || [ "$src" -nt "$app/Contents/Info.plist" ]; then
    if [ "${DRY_RUN:-0}" = "1" ]; then
      would "osacompile -o '$app' + stamp bundle id $bundle_id + lsregister"
    else
      mkdir -p "$HOME/Applications"
      rm -rf "$app"
      osacompile -o "$app" "$src"
      /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $bundle_id" \
        "$app/Contents/Info.plist" 2>/dev/null \
        || /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $bundle_id" \
          "$app/Contents/Info.plist"
      "$lsregister" -f "$app" 2>/dev/null || true
      rebuilt=true
      ok "built wrapper app: $app"
    fi
  fi

  # Diff-before-write: if the app is current and .md already resolves to our
  # wrapper, there's nothing to register — skip the duti pass entirely.
  if [ "$rebuilt" = false ] && [ "$(duti -x md 2>/dev/null | tail -1)" = "$bundle_id" ]; then
    return 0
  fi

  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "duti -s $bundle_id <markdown UTI + .md/.markdown/…> all"
    return 0
  fi

  local x
  for x in $utis; do duti -s "$bundle_id" "$x" all 2>/dev/null || true; done
  for x in $exts; do duti -s "$bundle_id" ".$x" all 2>/dev/null || true; done
  ok "markdown default app → nvim in Ghostty"
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
