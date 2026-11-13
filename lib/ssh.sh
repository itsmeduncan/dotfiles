#!/bin/bash
# SSH key generation. Defaults to a passphrase-protected key — users must
# explicitly type "unencrypted" to opt into the convenience-only insecure default.
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

ssh_run() {
  _ssh_key
  _ssh_tailnet_config
}

# Tailnet host settings (on-disk key, connection reuse) live in the repo as
# ssh/tailnet.conf. ~/.ssh/config stays untracked — this repo is public and that
# file holds host IPs — and only gains the Include line, at the top: ssh keeps
# the first value per keyword, so the include must precede any `Host *`.
_SSH_INCLUDE='Include ~/.ssh/config.d/*.conf'

_ssh_tailnet_config() {
  local cfg="$HOME/.ssh/config"
  link "$DOTFILES_DIR/ssh/tailnet.conf" "$HOME/.ssh/config.d/tailnet.conf"

  if [ -f "$cfg" ] && grep -qxF "$_SSH_INCLUDE" "$cfg"; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then ok "ssh config includes config.d"; fi
    return 0
  fi
  if [ "${CHECK_MODE:-0}" = "1" ]; then
    warn "$HOME/.ssh/config lacks '$_SSH_INCLUDE' (run ./install.sh --only=ssh)"
    return 0
  fi
  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "prepend '$_SSH_INCLUDE' to ~/.ssh/config"
    return 0
  fi

  local tmp
  tmp="$(mktemp "$HOME/.ssh/config.XXXXXX")"
  {
    printf '%s\n\n' "$_SSH_INCLUDE"
    [ -f "$cfg" ] && cat "$cfg"
  } >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$cfg"
  ok "ssh config now includes ~/.ssh/config.d"
}

_ssh_key() {
  if [ -f "$HOME/.ssh/id_ed25519" ]; then
    ok "SSH key present"
    return 0
  fi

  if [ "${CHECK_MODE:-0}" = "1" ]; then
    warn "no SSH key at ~/.ssh/id_ed25519"
    return 0
  fi

  if [ "${DRY_RUN:-0}" = "1" ]; then
    would "prompt for SSH key generation"
    return 0
  fi

  printf "No SSH key found. Generate one? (y/N) "
  read -r ssh_answer
  case "$ssh_answer" in
    y | Y) ;;
    *)
      log "Skipping SSH key generation."
      return 0
      ;;
  esac

  printf "Use a passphrase (recommended)? (Y/unencrypted) "
  read -r pass_answer
  local passphrase=""
  case "$pass_answer" in
    unencrypted)
      warn "Generating UNENCRYPTED SSH key. Add a passphrase later with: ssh-keygen -p -f ~/.ssh/id_ed25519"
      ;;
    *)
      log "ssh-keygen will prompt you for a passphrase below."
      # Empty passphrase arg passed to -N would skip the prompt — omit -N so
      # ssh-keygen handles passphrase interactively.
      passphrase="prompt"
      ;;
  esac

  mkdir -p "$HOME/.ssh"
  local email
  email="$(git config user.email 2>/dev/null || echo 'user@host')"

  if [ "$passphrase" = "prompt" ]; then
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519"
  else
    ssh-keygen -t ed25519 -C "$email" -N "" -f "$HOME/.ssh/id_ed25519"
  fi

  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/id_ed25519"
  log "Add your SSH key to GitHub: pbcopy < ~/.ssh/id_ed25519.pub"
}
