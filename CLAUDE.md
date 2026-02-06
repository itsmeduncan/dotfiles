# Dotfiles

Personal dotfiles for macOS (Apple Silicon). Managed by symlinks via `install.sh`.

## Setup

1. Install zsh, tmux, oh-my-zsh, and Spaceship Prompt (via Homebrew)
2. Run `./install.sh` to symlink all dotfiles to `$HOME`
3. Clone tpm: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

## Structure

All files in the repo root get symlinked to `~/.<filename>` by `install.sh`.

- **Shell:** `zshrc` (primary shell config, oh-my-zsh + Spaceship), `zprofile` (env vars, PATH), `profile` (bash fallback)
- **Git:** `gitconfig` (aliases, user config), `gitignore` (global ignores), `gitmessage` (commit template)
- **Editor:** `vimrc` (Vim config with Vundle plugin manager)
- **Terminal:** `tmux.conf` (tmux config with tpm plugin manager)
- **Other:** `gemrc`, `psqlrc`

## Key tools

- **Shell:** zsh + oh-my-zsh + Spaceship Prompt
- **Package manager:** Homebrew (`/opt/homebrew`)
- **Version manager:** mise (manages Node, Python, Ruby, and other runtimes)
- **Go:** GOPATH at `$HOME/Projects/`
- **Env management:** direnv
- **Modern CLI:** eza (ls), bat (cat), ripgrep (grep), fd (find), zoxide (cd), fzf (fuzzy finder), delta (git diffs)

## Conventions

- No secrets in dotfiles. Use `~/.bootstrap/env.sh` or direnv for secrets.
- Git aliases are short: `st`, `co`, `ci`, `br`, `d`, `f`, `p`, etc.
- Editor is set to `code` (VS Code) in profile, `vim` in gitconfig.
