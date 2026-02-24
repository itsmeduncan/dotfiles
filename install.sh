#!/bin/bash

set -e

# Dotfiles to symlink into $HOME
files=(editorconfig gemrc gitconfig gitignore gitmessage profile psqlrc tmux.conf vimrc zprofile zshrc)

# Homebrew dependencies
brews=(vim mise eza bat ripgrep fd zoxide fzf git-delta direnv tmux spaceship gh pre-commit)

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install brew packages
for pkg in "${brews[@]}"; do
  brew list "$pkg" &>/dev/null || brew install "$pkg"
done

# Symlink dotfiles
for file in "${files[@]}"; do
  ln -sf "$(pwd)/$file" "$HOME/.$file"
done

# Symlink bin directory
ln -sfn "$(pwd)/bin" "$HOME/.dotfiles/bin"

# Install oh-my-zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

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

# Install tmux plugins headlessly
if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi
