#!/bin/bash

set -e

# Xcode CLI tools (required for git, compilers, etc.)
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Press enter after Xcode tools finish installing."
  read -r
fi

# Dotfiles to symlink into $HOME
files=(bunfig.toml editorconfig gemrc gitconfig gitignore gitmessage npmrc psqlrc tmux.conf vimrc zprofile zshrc)

# Homebrew dependencies
brews=(
  # Core
  neovim mise eza bat ripgrep fd zoxide fzf git-delta direnv tmux gh pre-commit
  # Shell
  spaceship zsh-autosuggestions zsh-syntax-highlighting atuin
  # Dev tools
  uv pnpm lazygit jq yq watchman git-absorb yazi just hyperfine dust bottom tokei
  # Cloud & infra
  awscli terraform
  # Networking
  mosh nmap
  # Additional tools
  wget tldr
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

# SSH key
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$(git config user.email)" -N "" -f "$HOME/.ssh/id_ed25519"
  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/id_ed25519"
  echo "Add your SSH key to GitHub: pbcopy < ~/.ssh/id_ed25519.pub"
fi

# Symlink dotfiles
for file in "${files[@]}"; do
  ln -sf "$(pwd)/$file" "$HOME/.$file"
done

# Symlink bin directory (remove stale dir so the symlink lands correctly)
mkdir -p "$HOME/.dotfiles"
if [ -d "$HOME/.dotfiles/bin" ] && [ ! -L "$HOME/.dotfiles/bin" ]; then
  rm -rf "$HOME/.dotfiles/bin"
fi
ln -sfn "$(pwd)/bin" "$HOME/.dotfiles/bin"

# Symlink nvim config
mkdir -p "$HOME/.config"
ln -sfn "$(pwd)/config/nvim" "$HOME/.config/nvim"

# Symlink yazi config
ln -sfn "$(pwd)/config/yazi" "$HOME/.config/yazi"

# Symlink uv config
ln -sfn "$(pwd)/config/uv" "$HOME/.config/uv"

# Symlink pnpm config
mkdir -p "$HOME/Library/Preferences"
ln -sfn "$(pwd)/config/pnpm" "$HOME/Library/Preferences/pnpm"

# Install oh-my-zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install runtimes via mise
eval "$(mise activate bash)"
mise use -g node@lts python@3 ruby@3 go@latest 2>/dev/null || true

# Install Android development tools via mise
mise install java@temurin-17 2>/dev/null || true
mise use -g java@temurin-17 2>/dev/null || true

# Install Android SDK via Homebrew (Android Studio not required)
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
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

# Install Neovim plugins headlessly
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

# Rust
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
if [ "$defaults_changed" = true ]; then
  killall Finder 2>/dev/null || true
  killall Dock 2>/dev/null || true
fi

# Claude Code config (profile-wide CLAUDE.md, settings, agents)
mkdir -p "$HOME/.claude"
ln -sf "$(pwd)/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$(pwd)/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$(pwd)/claude/agents" "$HOME/.claude/agents"
ln -sfn "$(pwd)/claude/skills" "$HOME/.claude/skills"
ln -sfn "$(pwd)/claude/rules" "$HOME/.claude/rules"
ln -sfn "$(pwd)/claude/hooks" "$HOME/.claude/hooks"
ln -sf "$(pwd)/claude/statusline.sh" "$HOME/.claude/statusline.sh"
