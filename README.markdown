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
* Install a slim Homebrew set — only things mise can't manage or that are tightly coupled to brew:
  * **Bootstrap:** mise
  * **System integration:** tmux, postgresql, watchman
  * **Shell plugins (sourced from brew paths in zshrc):** spaceship, zsh-autosuggestions, zsh-syntax-highlighting
  * **Networking:** mosh, nmap, wget
  * **Docs / files:** tldr, yazi
  * **Other:** git-absorb, cocoapods (ruby gem)
* Install GUI apps via Homebrew Cask: Ghostty, OrbStack, 1Password, Slack, Notion, Tailscale, LM Studio, gcloud-cli
* Install [MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts)
* Generate SSH key (ed25519) if missing
* Symlink all dotfiles to `$HOME`
* Symlink config directories (`nvim`, `yazi`, `uv`, `opencode`) to `~/.config/`, `pnpm` to `~/Library/Preferences/`
* Symlink `mise.toml` to `~/.config/mise/config.toml`
* Symlink `bin/` utilities to `~/.dotfiles/bin/`
* Symlink shared agent skills from `agents/skills/` to `~/.agents/skills` and `~/.pi/agent/skills`
* Install [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) if missing
* Install everything declared in `mise.toml` via [mise](https://mise.jdx.dev) — all language runtimes (Node, Python, Ruby, Go, Java, Bun) plus most CLI tools (neovim, eza, bat, ripgrep, fd, zoxide, fzf, delta, direnv, gh, lazygit, pre-commit, uv, pnpm, just, jq, yq, hyperfine, dust, bottom, tokei, awscli, terraform, opencode, swiftlint, atuin)
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
