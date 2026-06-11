#!/bin/bash
# All symlink-into-$HOME and into ~/.config logic.
# Uses the `link()` helper from _common.sh — every call is idempotent,
# respects DRY_RUN, and reports drift under CHECK_MODE.
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

# Files in repo root that get symlinked to ~/.<name>
_HOME_FILES=(
  bunfig.toml gemrc gitconfig gitignore gitmessage
  npmrc psqlrc tmux.conf vimrc zprofile zshrc
)

symlinks_run() {
  # Home-dir dotfiles
  for file in "${_HOME_FILES[@]}"; do
    link "$DOTFILES_DIR/$file" "$HOME/.$file"
  done

  # ~/.dotfiles/bin (stale dir cleanup before symlinking)
  if [ -d "$HOME/.dotfiles/bin" ] && [ ! -L "$HOME/.dotfiles/bin" ]; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then
      warn "~/.dotfiles/bin exists as a directory (should be a symlink)"
    else
      run "rm -rf ~/.dotfiles/bin (stale dir)" rm -rf "$HOME/.dotfiles/bin"
    fi
  fi
  link "$DOTFILES_DIR/bin" "$HOME/.dotfiles/bin"

  # ~/.config/* symlinks
  link "$DOTFILES_DIR/config/nvim"            "$HOME/.config/nvim"
  link "$DOTFILES_DIR/config/yazi"            "$HOME/.config/yazi"
  link "$DOTFILES_DIR/config/ghostty/config"  "$HOME/.config/ghostty/config"
  link "$DOTFILES_DIR/config/bat/config"      "$HOME/.config/bat/config"
  link "$DOTFILES_DIR/config/uv"              "$HOME/.config/uv"
  link "$DOTFILES_DIR/config/opencode/opencode.json" \
                                              "$HOME/.config/opencode/opencode.json"

  # pnpm config lives under ~/Library/Preferences on macOS
  link "$DOTFILES_DIR/config/pnpm" "$HOME/Library/Preferences/pnpm"
}
