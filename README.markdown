# Dotfiles

Personal dotfiles for macOS (Apple Silicon). See [CHANGELOG.md](CHANGELOG.md) for notable changes.

## Install

```bash
git clone git@github.com:itsmeduncan/dotfiles.git
cd dotfiles
./install.sh
```

### Flags

- `--dry-run` — preview every mutating action as `[DRY] would: ...` without executing
- `--check` — audit mode: report drift (symlinks, Brewfile, mise, macOS defaults), change nothing
- `--skip=a,b` / `--only=a,b` — skip or isolate phases: `preflight brew symlinks mise agents runtimes android macos ssh`
- `--snapshot` — write `bootstrap-state.snapshot` recording current versions of every brew/mise tool, submodule, and plugin

The installer is idempotent and skips already-satisfied work (Brewfile check, nvim lazy-lock hash, tmux plugin dirs).

### What it does

`install.sh` is a thin orchestrator over phase modules in `lib/`:

- **brew** — install [Homebrew](https://brew.sh) if missing, then sync the [`Brewfile`](Brewfile): a slim set of things mise can't manage (tmux, postgresql@18, watchman, zsh plugins, mosh/nmap/wget, tldr, yazi, git-absorb, cocoapods) plus GUI casks (Ghostty, OrbStack, 1Password + CLI, Slack, Notion, Tailscale, Ollama, gcloud-cli, MesloLGS Nerd Font)
- **symlinks** — all dotfiles to `$HOME`; config dirs (`nvim`, `yazi`, `uv`, `bat`, `ghostty`, `opencode`) to `~/.config/`; `pnpm` to `~/Library/Preferences/`; `bin/` utilities to `~/.dotfiles/bin/`
- **mise** — symlink [`mise.toml`](mise.toml) to `~/.config/mise/config.toml`, then install everything declared there via [mise](https://mise.jdx.dev): all language runtimes (Node, Python, Ruby, Go, Java, Bun) plus most CLI tools (neovim, eza, bat, ripgrep, fd, zoxide, fzf, delta, direnv, gh, lazygit, pre-commit, uv, pnpm, just, jq, yq, hyperfine, dust, bottom, tokei, awscli, terraform, opencode, swiftlint, atuin, pi-coding-agent)
- **agents** — shared agent skills from `agents/skills/` to `~/.claude/skills`, `~/.agents/skills`, and `~/.pi/agent/skills`; Claude Code config to `~/.claude/`
- **runtimes** — oh-my-zsh, [Rust](https://rustup.rs) via rustup, [tpm](https://github.com/tmux-plugins/tpm) + tmux plugins, Neovim plugins via lazy.nvim
- **android** — Android SDK via Homebrew commandlinetools (only when missing)
- **macos** — productivity defaults (key repeat, Finder, Dock; version-aware, diff-before-write), application firewall
- **ssh** — generate an ed25519 key if missing (passphrase-protected by default)

## Reproducibility

- [`mise.toml`](mise.toml) pins every runtime and CLI tool version
- [`.tool-versions`](.tool-versions) (asdf format, runtimes only) is generated from it via `bin/sync-tool-versions` — CI fails if they drift
- `./install.sh --snapshot` writes [`bootstrap-state.snapshot`](bootstrap-state.snapshot), a human-diffable record of the last-known-good system state

## Git commit signing

The tracked `gitconfig` wires up SSH signing via 1Password's `op-ssh-sign` but leaves it **off** — enable per machine in `~/.gitconfig.local` (loaded via `includeIf`, safe if missing):

```ini
[user]
    signingKey = ssh-ed25519 AAAA... your-key
[commit]
    gpgsign = true
[tag]
    gpgsign = true
```

## CI

`.github/workflows/ci.yml`:

- **Tier-1** (Ubuntu, every push/PR): `bash -n`, shellcheck, shfmt, JSON/YAML validation, prettier, gitleaks secret scan, `.tool-versions` sync check
- **Tier-2** (macOS, PRs to master): `./install.sh --dry-run`, then a real end-to-end install on a clean runner, then `./install.sh --check`

Pre-commit hooks (`.pre-commit-config.yaml`) run the same linters locally: `pre-commit install` once, then they fire on every commit.

## Agent skills

Global cross-agent skills live in `agents/skills/`.

Claude consumes them through `claude/skills -> ../agents/skills`.
Codex discovers them through `~/.agents/skills`. OpenCode is configured
with `skills.paths` in `config/opencode/opencode.json`. Pi gets the
same tree at `~/.pi/agent/skills` for agents that know to inspect a
local skills directory.
