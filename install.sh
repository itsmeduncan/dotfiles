#!/bin/bash

set -e

# Dotfiles to symlink into $HOME
files=(gemrc gitconfig gitignore gitmessage profile psqlrc tmux.conf vimrc zprofile zshrc)

# Homebrew dependencies
brews=(mise eza bat ripgrep fd zoxide fzf git-delta direnv tmux spaceship)

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

# Install oh-my-zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install tmux plugin manager if missing
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
