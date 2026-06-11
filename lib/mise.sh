#!/bin/bash
# mise: symlink the pinned tool manifest and install everything declared in it.
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

mise_run() {
  link "$DOTFILES_DIR/mise.toml" "$HOME/.config/mise/config.toml"

  if ! command -v mise &>/dev/null; then
    warn "mise not on PATH yet — skipping install (brew should have provided it earlier)"
    return 0
  fi

  if [ "${CHECK_MODE:-0}" = "1" ]; then
    if mise current &>/dev/null && ! mise current 2>&1 | grep -qiE 'missing|not installed'; then
      ok "mise tools satisfied"
    else
      warn "mise tools drift — run 'mise install'"
    fi
    return 0
  fi

  log "Activating mise + installing pinned tools..."
  # shellcheck disable=SC1091
  eval "$(mise activate bash)"

  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "mise install"
  else
    if ! mise install; then
      warn "mise install reported errors; downstream steps may fail"
    fi
  fi
}
