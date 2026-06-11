#!/bin/bash
# Bootstraps non-mise runtimes and editor/multiplexer plugins:
# oh-my-zsh, rustup, tmux plugin manager, Neovim plugins.
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

runtimes_run() {
  # oh-my-zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then
      warn "oh-my-zsh not installed"
    else
      log "Installing oh-my-zsh..."
      run "install oh-my-zsh" sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
    fi
  else
    ok "oh-my-zsh present"
  fi

  # Rust (rustup — mise can manage rust but rustup is canonical for the
  # full toolchain including rustfmt/clippy/cross-target installs).
  if ! command -v rustup &>/dev/null; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then
      warn "rustup not installed"
    else
      log "Installing Rust via rustup..."
      run "install rustup" \
        sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    fi
  else
    ok "rustup present"
  fi

  # tmux plugin manager
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then
      warn "tpm not installed"
    else
      log "Installing tpm..."
      run "git clone tpm" git clone https://github.com/tmux-plugins/tpm \
        "$HOME/.tmux/plugins/tpm"
    fi
  else
    ok "tpm present"
  fi

  # Seed tmux-resurrect dir so continuum auto-restore doesn't error on first launch.
  if [ "${CHECK_MODE:-0}" != "1" ] && [ "${DRY_RUN:-0}" != "1" ]; then
    mkdir -p "$HOME/.tmux/resurrect"
    [ -f "$HOME/.tmux/resurrect/last" ] || touch "$HOME/.tmux/resurrect/last"
  fi

  # tmux plugin install (headless)
  if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ] \
    && [ "${CHECK_MODE:-0}" != "1" ]; then
    if [ "${DRY_RUN:-0}" = "1" ]; then
      would "install tmux plugins via tpm"
    else
      log "Installing tmux plugins..."
      "$HOME/.tmux/plugins/tpm/bin/install_plugins" \
        || warn "tmux plugin installation failed"
    fi
  fi

  # Neovim plugins (headless via lazy.nvim)
  if command -v nvim &>/dev/null && [ "${CHECK_MODE:-0}" != "1" ]; then
    if [ "${DRY_RUN:-0}" = "1" ]; then
      would "nvim --headless +Lazy! sync +qa"
    else
      log "Syncing Neovim plugins..."
      nvim --headless "+Lazy! sync" +qa 2>&1 \
        || warn "Neovim plugin installation failed"
    fi
  fi
}
