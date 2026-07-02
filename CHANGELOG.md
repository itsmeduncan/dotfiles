# Changelog

All notable changes to this repo, in human terms. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] — modernization branch

### Added

- **`mise.toml`** — single pinned manifest for all language runtimes and most CLI tools (27 tools migrated from Homebrew). Reproducible across machines; upgrade with `mise upgrade --bump`.
- **`Brewfile`** — declarative manifest for the remaining Homebrew set (mise bootstrap, casks, system tools). Replaces the inline `brews=(…)` array. Supports `brew bundle check` for drift detection.
- **`lib/` modules** — `install.sh` split into 9 phase modules (preflight, brew, symlinks, mise, agents, runtimes, android, macos, ssh) sharing helpers via `lib/_common.sh`. Each phase exposes `<name>_run`.
- **`install.sh --dry-run`** — print every mutating action as `[DRY] would: …` without executing.
- **`install.sh --check`** — audit mode: report drift in symlinks / Brewfile / mise / macOS defaults without changes.
- **`install.sh --skip=<phase>` / `--only=<phase>`** — selective phase execution.
- **Structured logging** — `log/ok/warn/err` helpers with colored stderr output (TTY-only).
- **`link()` helper** — idempotent symlink with parent dir creation. All 17 ln-sf sites migrated.
- **`.pre-commit-config.yaml`** — shellcheck, shfmt, prettier, gitleaks, plus standard pre-commit hooks. Wires up the `pre-commit` framework that was already installed but unused.
- **`.github/workflows/ci.yml`** — Tier-1 lint (Ubuntu, every push/PR): bash -n, shellcheck, shfmt, prettier check, JSON/YAML validation, gitleaks. Tier-2 install (macOS, on PR to main / dispatch): dry-run + real installer end-to-end + `--check` verification.
- **1Password SSH commit signing** — gitconfig now has `commit.gpgsign = true`, `gpg.format = ssh`, and points at 1Password's `op-ssh-sign`. Placeholder `signingKey` — override locally.
- **`CHANGELOG.md`** — this file.
- **Pi config tracked under `pi/`** — `pi/models.json` (lmstudio + darksaber local providers, Anthropic key via `!op read` from 1Password) and `pi/settings.json` (local-first default model) are now symlinked into `~/.pi/agent/` by the agents phase. Reproducible on a new machine; no secrets in the repo (`auth.json` stays machine-local).
- **tmux popups** — `prefix g` opens lazygit in a 90% centered popup at the current pane's path; `prefix f` opens an fzf session switcher.
- **tmux prefix indicator** — the session block in the status bar turns amber while the prefix key is armed, for visual feedback.
- **Statusline git state + color** — `claude/statusline.sh` now shows a `✱` dirty marker and `↑↓` ahead/behind counts next to the branch, and color-grades context usage (green < 50%, yellow < 80%, red ≥ 80%).
- **Battery low-charge color** — `bin/battery` flags the status-bar reading red when below 20% and unplugged.
- **Pi local-first default** — `Qwen3-Coder-30B-A3B-Instruct-MLX` is now the first lmstudio model and the default provider/model for Pi (agentic coding tuned, runs on the M5 Max).
- **Obsidian cask** — the Obsidian desktop app is now brew-managed, alongside the existing `obsidian.nvim` workflow over the `~/notes/` vault.
- **iCloud notes vault** — the `~/notes/` Obsidian vault now lives in iCloud Drive (`com~apple~CloudDocs/notes`), with `~/notes` symlinked to it. The symlinks phase links it idempotently on new machines once iCloud has synced, and never clobbers a real `~/notes` directory.
- **tmux Pomodoro timer** — `tmux-pomodoro-plus` (tpm). `prefix p` start/pause, `P` cancel, `_` skip. The countdown is always shown in the status bar (` 🍅 --` placeholder when idle, spaced ` 🍅 25m` when running) via a new `bin/pomodoro-status` wrapper; desktop notifications are off. `prefix p` now overrides tmux's default previous-window binding.

### Changed

- **Tailscale moved to the `tailscale-app` cask** — was installed via the Mac App Store, which Homebrew can't see, so `brew bundle check` reported permanent drift and re-ran `brew bundle install` every time. Now brew-owned and reproducible.
- **Homebrew scope reduced** from ~30 packages to 12: only what mise can't manage or what's tightly coupled to brew (services, zsh plugin assets, system networking, GUI casks).
- **`mise install` failures are now warnings**, not fatal — downstream symlinks and config still land.
- **SSH keygen defaults to passphrase-protected key.** Typing `unencrypted` at the second prompt is required to opt into the convenience-only default.
- **macOS defaults are version-aware** via an optional `min_macos_major` arg to `set_default`. Skipped on non-Darwin (CI-friendly).
- **`AGENTS.md` is now a symlink to `CLAUDE.md`** — single source of truth, no more drift between the two.
- **Greptile submodule URL** switched from SSH to HTTPS so forkers without SSH auth can clone.

### Removed

- `mise pip install pidev` — `pidev` no longer exists; Pi is now installed via mise's `npm:@mariozechner/pi-coding-agent` backend declared in `mise.toml`.
- Inline `brews=(…)` array in install.sh (moved to Brewfile).
- `declare -A cask_app_names` — replaced with a `case` statement compatible with stock macOS bash 3.2.

### Fixed

- **bash 3.2 `unbound variable` on cask install** — stock macOS bash doesn't support associative arrays; with `set -u` the lookup tripped on the first cask. Now uses a portable `case` statement.
- **Stale docs across `CLAUDE.md`, `AGENTS.md`, `README.markdown`** — cask list, skill inventory, mise vs Homebrew split, pi-coding-agent reference.
- **`pi` not on PATH after node version bump** — `pi` was installed under the old node mise install dir. Pinning it via mise's `npm:` backend in `mise.toml` makes it follow whichever node version is active.

### Security

- Added `gitleaks` to pre-commit and CI to catch accidentally-committed secrets.
- SSH key generation now defaults to a passphrase-protected key.
- Commits/tags are signed by default via 1Password SSH-signing.
