#!/bin/bash
# Homebrew bootstrap + Brewfile sync.
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

brew_run() {
  # Install Homebrew itself if missing.
  if ! command -v brew &>/dev/null; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then
      warn "Homebrew not installed"
      return 0
    fi
    log "Installing Homebrew..."
    run "install homebrew" /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Ensure Apple Silicon brew is on PATH.
  if [ -f /opt/homebrew/bin/brew ]; then
    # shellcheck disable=SC1091
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  if [ "${CHECK_MODE:-0}" = "1" ]; then
    if brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
      ok "Brewfile satisfied"
    else
      warn "Brewfile drift — run 'brew bundle install --file=Brewfile'"
    fi
    return 0
  fi

  # Skip the install pass entirely when Brewfile is already satisfied —
  # `brew bundle check` is ~1s, `brew bundle install` is ~5s + network even
  # in the no-op case. Saves repeated work on re-runs.
  if brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
    ok "Brewfile already satisfied — skipping install"
    return 0
  fi

  log "Syncing Brewfile..."
  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "brew bundle install --file=$DOTFILES_DIR/Brewfile"
  else
    if ! brew bundle install --file="$DOTFILES_DIR/Brewfile"; then
      warn "brew bundle install reported errors; continuing"
    fi
  fi
}
