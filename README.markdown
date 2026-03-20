# Dotfiles

Personal dotfiles for macOS (Apple Silicon).

## Install

```bash
git clone git@github.com:itsmeduncan/dotfiles.git
cd dotfiles
./install.sh
```

The install script will:

* Install [Homebrew](https://brew.sh) if missing
* Install dependencies via Homebrew:
  * **Core:** neovim, mise, eza, bat, ripgrep, fd, zoxide, fzf, git-delta, direnv, tmux, gh, pre-commit
  * **Shell:** spaceship, zsh-autosuggestions, zsh-syntax-highlighting, atuin
  * **Dev tools:** uv, pnpm, lazygit, jq, yq, watchman, git-absorb, yazi, just, hyperfine, dust, bottom, tokei
  * **Mobile:** cocoapods, swiftlint
* Install [MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts)
* Symlink all dotfiles to `$HOME`
* Symlink config directories (`nvim`, `yazi`) to `~/.config/`
* Symlink `bin/` utilities to `~/.dotfiles/bin/`
* Install [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) if missing
* Install runtimes via [mise](https://mise.jdx.dev) (Node LTS, Python 3, Ruby 3, Java Temurin 17)
* Install Android SDK via Homebrew commandlinetools
* Install [tpm](https://github.com/tmux-plugins/tpm) and tmux plugins
* Install Neovim plugins via lazy.nvim
* Set macOS productivity defaults (key repeat, Finder, Dock)
* Symlink Claude Code config (`~/.claude/`)
