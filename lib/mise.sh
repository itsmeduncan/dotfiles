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
    # `mise activate` updates PATH from a prompt hook, which never runs in a
    # script: refresh it now so later phases find the tools just installed
    # (nvim for the plugin sync, pre-commit below).
    eval "$(mise hook-env -s bash)"
  fi

  _precommit_hook
}

# The repo's gitleaks/shellcheck/shfmt gate only runs if the git hook is
# installed in this clone.
_precommit_hook() {
  [ -d "$DOTFILES_DIR/.git" ] || [ -f "$DOTFILES_DIR/.git" ] || return 0
  local hook
  hook="$(git -C "$DOTFILES_DIR" rev-parse --git-path hooks/pre-commit)"
  case "$hook" in /*) ;; *) hook="$DOTFILES_DIR/$hook" ;; esac
  if [ -f "$hook" ] && grep -q pre-commit "$hook"; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then ok "pre-commit hook installed"; fi
    return 0
  fi
  if [ "${CHECK_MODE:-0}" = "1" ]; then
    warn "pre-commit hook not installed (run: pre-commit install)"
    return 0
  fi
  if ! command -v pre-commit &>/dev/null; then
    warn "pre-commit not on PATH; run 'pre-commit install' in $DOTFILES_DIR later"
    return 0
  fi
  # Only the git hook: no --install-hooks. Building every hook environment
  # (node, go, python) needs the network and failed in CI; pre-commit builds
  # them on the first commit instead.
  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "pre-commit install"
    return 0
  fi
  local out
  if ! out="$(cd "$DOTFILES_DIR" && pre-commit install -f 2>&1)"; then
    warn "pre-commit install failed: $out"
  fi
}
