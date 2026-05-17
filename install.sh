#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Xcode CLI tools (required for git, compilers, etc.)
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Press enter after Xcode tools finish installing."
  read -r
fi

# Dotfiles to symlink into $HOME
files=(bunfig.toml gemrc gitconfig gitignore gitmessage npmrc psqlrc tmux.conf vimrc zprofile zshrc)

# Homebrew dependencies
brews=(
  # Core
  neovim mise eza bat ripgrep fd zoxide fzf git-delta direnv tmux gh pre-commit
  # Shell
  spaceship zsh-autosuggestions zsh-syntax-highlighting atuin
  # Dev tools
  uv pnpm lazygit jq yq watchman git-absorb yazi just hyperfine dust bottom tokei postgresql
  # Cloud & infra
  awscli terraform
  # Networking
  mosh nmap
  # Additional tools
  wget tldr opencode
  # Mobile
  cocoapods swiftlint
)

# GUI applications
casks=(
  ghostty
  orbstack
  1password
  slack
  notion
  tailscale
  lm-studio
  gcloud-cli
)

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure Apple Silicon Homebrew is on PATH (installs to /opt/homebrew on ARM Macs)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install brew packages
for pkg in "${brews[@]}"; do
  brew list "$pkg" &>/dev/null || brew install "$pkg"
done

# Map cask tokens to their .app names for detecting non-Homebrew installs
declare -A cask_app_names=(
  [ghostty]="Ghostty"
  [orbstack]="OrbStack"
  [1password]="1Password"
  [slack]="Slack"
  [notion]="Notion"
  [tailscale]="Tailscale"
  [lm-studio]="LM Studio"
)

# Install cask applications (skip if already installed via brew or directly)
for app in "${casks[@]}"; do
  app_name="${cask_app_names[$app]}"
  if brew list --cask "$app" &>/dev/null; then
    continue
  elif [ -n "$app_name" ] && [ -d "/Applications/${app_name}.app" ]; then
    continue
  fi
  brew install --cask "$app" || true
done

# Install Nerd Font
if ! brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
  brew install --cask font-meslo-lg-nerd-font
fi

# SSH key (unencrypted — convenient but less secure; use a passphrase for sensitive machines)
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "No SSH key found. Generate one? (y/N)"
  read -r ssh_answer
  if [ "$ssh_answer" = "y" ] || [ "$ssh_answer" = "Y" ]; then
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$(git config user.email 2>/dev/null || echo 'user@host')" -N "" -f "$HOME/.ssh/id_ed25519"
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"
    echo "Add your SSH key to GitHub: pbcopy < ~/.ssh/id_ed25519.pub"
  else
    echo "Skipping SSH key generation."
  fi
fi

# Symlink dotfiles
for file in "${files[@]}"; do
  ln -sf "$DOTFILES_DIR/$file" "$HOME/.$file"
done

# Symlink bin directory (remove stale dir so the symlink lands correctly)
mkdir -p "$HOME/.dotfiles"
if [ -d "$HOME/.dotfiles/bin" ] && [ ! -L "$HOME/.dotfiles/bin" ]; then
  rm -rf "$HOME/.dotfiles/bin"
fi
ln -sfn "$DOTFILES_DIR/bin" "$HOME/.dotfiles/bin"

# Symlink nvim config
mkdir -p "$HOME/.config"
ln -sfn "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

# Symlink yazi config
ln -sfn "$DOTFILES_DIR/config/yazi" "$HOME/.config/yazi"

# Symlink ghostty config
mkdir -p "$HOME/.config/ghostty"
ln -sfn "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"

# Symlink bat config
mkdir -p "$HOME/.config/bat"
ln -sfn "$DOTFILES_DIR/config/bat/config" "$HOME/.config/bat/config"

# Symlink uv config
ln -sfn "$DOTFILES_DIR/config/uv" "$HOME/.config/uv"

# Symlink pnpm config
mkdir -p "$HOME/Library/Preferences"
ln -sfn "$DOTFILES_DIR/config/pnpm" "$HOME/Library/Preferences/pnpm"

# Setup opencode config
mkdir -p "$HOME/.config/opencode"
ln -sf "$DOTFILES_DIR/config/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

# Create opencode auth file with placeholder if missing
mkdir -p "$HOME/.local/share/opencode"
if [ ! -f "$HOME/.local/share/opencode/auth.json" ]; then
  cat > "$HOME/.local/share/opencode/auth.json" << 'EOF'
{
  "lm-studio": {
    "type": "api",
    "key": "sk-local"
  }
}
EOF
fi

# Shared agent skills. Claude, Codex, OpenCode, Pi, and other agents should
# treat this as the canonical global skill tree.
mkdir -p "$HOME/.agents" "$HOME/.pi/agent"
ln -sfn "$DOTFILES_DIR/agents/skills" "$HOME/.agents/skills"
ln -sfn "$DOTFILES_DIR/agents/skills" "$HOME/.pi/agent/skills"

# Install oh-my-zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install runtimes via mise
eval "$(mise activate bash)"
mise use -g node@lts python@3 ruby@3 go@latest 2>/dev/null || true

# Install global Python packages via mise
mise pip install pidev 2>/dev/null || true

# Install Android development tools via mise
mise install java@temurin-17 2>/dev/null || true
mise use -g java@temurin-17 2>/dev/null || true

# Install Android SDK via Homebrew (Android Studio not required)
# Note: sdkmanager --licenses is auto-accepted with `yes |` for convenience.
# Review licenses manually if needed: sdkmanager --sdk_root="$HOME/Library/Android/sdk" --licenses
if [ ! -d "$HOME/Library/Android/sdk" ]; then
  brew install --cask android-commandlinetools
  yes | sdkmanager --sdk_root="$HOME/Library/Android/sdk" \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "emulator"
  yes | sdkmanager --sdk_root="$HOME/Library/Android/sdk" --licenses
fi

# Install tmux plugin manager if missing
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Seed tmux-resurrect dir so continuum auto-restore doesn't error on first launch
mkdir -p "$HOME/.tmux/resurrect"
if [ ! -f "$HOME/.tmux/resurrect/last" ]; then
  touch "$HOME/.tmux/resurrect/last"
fi

# Install tmux plugins headlessly
if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  if ! "$HOME/.tmux/plugins/tpm/bin/install_plugins"; then
    echo "WARNING: tmux plugin installation failed."
  fi
fi

# Install Neovim plugins headlessly
if ! nvim --headless "+Lazy! sync" +qa 2>&1; then
  echo "WARNING: Neovim plugin installation failed."
fi

# Rust (auto-accepts installation; review rustup terms if needed)
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# macOS productivity defaults (only write if value differs, restart apps only if changed)
defaults_changed=false

set_default() {
  local domain="$1" key="$2" type="$3" value="$4"
  local current
  current=$(defaults read "$domain" "$key" 2>/dev/null) || current=""
  if [ "$current" != "$value" ]; then
    defaults write "$domain" "$key" "$type" "$value"
    defaults_changed=true
  fi
}

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

# Disable smart quotes and dashes
set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Expand save and print panels by default
set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
set_default NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Trackpad tap to click
set_default com.apple.AppleMultitouchTrackpad Clicking -bool true
set_default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Firewall (only enable if not already on)
if ! /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep -q "enabled"; then
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null || true
fi

# Restart Finder and Dock only if defaults changed
# Note: this closes all open Finder windows. Use --no-restart to skip.
if [ "$defaults_changed" = true ]; then
  killall Finder 2>/dev/null || true
  killall Dock 2>/dev/null || true
fi

# Claude Code config (profile-wide CLAUDE.md, settings, agents)
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$DOTFILES_DIR/claude/agents" "$HOME/.claude/agents"
ln -sfn "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"
ln -sfn "$DOTFILES_DIR/claude/rules" "$HOME/.claude/rules"
ln -sfn "$DOTFILES_DIR/claude/hooks" "$HOME/.claude/hooks"
ln -sf "$DOTFILES_DIR/claude/statusline.sh" "$HOME/.claude/statusline.sh"
