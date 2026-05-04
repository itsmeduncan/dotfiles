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
  * **Dev tools:** uv, pnpm, lazygit, jq, yq, watchman, git-absorb, yazi, just, hyperfine, dust, bottom, tokei, postgresql
  * **Cloud & infra:** awscli, terraform, gcloud-cli (Google Cloud CLI, installed as cask)
  * **Networking:** mosh, nmap
  * **Additional tools:** wget, tldr, opencode
  * **Mobile:** cocoapods, swiftlint
* Install GUI apps via Homebrew Cask: Ghostty, OrbStack, 1Password, Slack, Notion, Tailscale, LM Studio
* Install [MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts)
* Generate SSH key (ed25519) if missing
* Symlink all dotfiles to `$HOME`
* Symlink config directories (`nvim`, `yazi`, `uv`, `opencode`) to `~/.config/`, `pnpm` to `~/Library/Preferences/`
* Symlink `bin/` utilities to `~/.dotfiles/bin/`
* Symlink shared agent skills from `agents/skills/` to `~/.agents/skills` and `~/.pi/agent/skills`
* Install [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) if missing
* Install runtimes via [mise](https://mise.jdx.dev) (Node LTS, Python 3, Ruby 3, Go, Java Temurin 17)
* Install [Rust](https://rustup.rs) via rustup if missing
* Install Android SDK via Homebrew commandlinetools
* Install [tpm](https://github.com/tmux-plugins/tpm) and tmux plugins
* Install Neovim plugins via lazy.nvim
* Set macOS productivity defaults (key repeat, Finder, Dock)
* Enable macOS application firewall
* Symlink Claude Code config (`~/.claude/`)

## Agent skills

Global cross-agent skills live in `agents/skills/`.

Claude consumes them through `claude/skills -> ../agents/skills`.
Codex discovers them through `~/.agents/skills`. OpenCode is configured
with `skills.paths` in `config/opencode/opencode.json`. Pi gets the
same tree at `~/.pi/agent/skills` for agents that know to inspect a
local skills directory.
