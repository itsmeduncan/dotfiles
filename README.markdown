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
* Install dependencies: mise, eza, bat, ripgrep, fd, zoxide, fzf, git-delta, direnv, tmux, spaceship
* Symlink all dotfiles to `$HOME`
* Install [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) if missing
* Install [tpm](https://github.com/tmux-plugins/tpm) (tmux plugin manager) if missing

## Post-install

Set up global runtimes with [mise](https://mise.jdx.dev):

```bash
mise use -g node@lts
mise use -g python@3
mise use -g ruby@3
```
