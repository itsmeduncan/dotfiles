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
files=(editorconfig gemrc gitconfig gitignore gitmessage psqlrc tmux.conf vimrc zprofile zshrc)

# Homebrew dependencies
brews=(
  # Core
  neovim mise eza bat ripgrep fd zoxide fzf git-delta direnv tmux gh pre-commit
  # Shell
  spaceship zsh-autosuggestions zsh-syntax-highlighting atuin
  # Dev tools
  uv pnpm lazygit jq yq watchman git-absorb yazi just hyperfine dust bottom tokei
  # Mobile
  cocoapods swiftlint
)

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install brew packages
for pkg in "${brews[@]}"; do
  brew list "$pkg" &>/dev/null || brew install "$pkg"
done

# Install Nerd Font
if ! brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
  brew install --cask font-meslo-lg-nerd-font
fi

# Symlink dotfiles
for file in "${files[@]}"; do
  ln -sf "$(pwd)/$file" "$HOME/.$file"
done

# Symlink bin directory
ln -sfn "$(pwd)/bin" "$HOME/.dotfiles/bin"

# Symlink nvim config
mkdir -p "$HOME/.config"
ln -sfn "$(pwd)/config/nvim" "$HOME/.config/nvim"

# Symlink yazi config
ln -sfn "$(pwd)/config/yazi" "$HOME/.config/yazi"

# Install oh-my-zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install runtimes via mise
eval "$(mise activate bash)"
mise use -g node@lts python@3 ruby@3 2>/dev/null || true

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

# macOS productivity defaults
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.NSScrollAnimationEnabled -bool false

# Claude Code config (profile-wide CLAUDE.md, settings, agents)
mkdir -p "$HOME/.claude"
ln -sf "$(pwd)/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$(pwd)/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$(pwd)/claude/agents" "$HOME/.claude/agents"
