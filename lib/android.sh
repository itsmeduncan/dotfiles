#!/bin/bash
# Android SDK setup (only runs when ~/Library/Android/sdk is missing).
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

android_run() {
  if [ -d "$HOME/Library/Android/sdk" ]; then
    ok "Android SDK present"
    return 0
  fi

  if [ "${CHECK_MODE:-0}" = "1" ]; then
    warn "Android SDK not installed"
    return 0
  fi

  log "Installing Android SDK (commandlinetools cask + sdkmanager components)..."
  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "brew install --cask android-commandlinetools"
    would "sdkmanager install platform-tools, platforms;android-35, build-tools;35.0.0, emulator"
    would "sdkmanager accept SDK licenses"
    return 0
  fi

  brew install --cask android-commandlinetools

  # Note: sdkmanager --licenses is auto-accepted. Review manually if needed:
  #   sdkmanager --sdk_root="$HOME/Library/Android/sdk" --licenses
  yes | sdkmanager --sdk_root="$HOME/Library/Android/sdk" \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "emulator"
  yes | sdkmanager --sdk_root="$HOME/Library/Android/sdk" --licenses
}
