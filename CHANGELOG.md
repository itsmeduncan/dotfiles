# Changelog

All notable changes to this repo, in human terms. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] — modernization branch

### Added

- **Hooks: `bash-guard.sh`, `context-guard.sh`, `scriptorium-session.sh`**, and `test-hooks.sh` (behavior tests for every hook and the status line, including a stdin that never closes). Every hook reads exactly one JSON value from stdin: Claude Code sometimes keeps stdin open, and an EOF reader hangs to its timeout and fails open.
- **`bin/lint-shell`** — one shell lint for CI that finds every first-party script by shebang.
- **`ssh/tailnet.conf`** — tailnet hosts use the on-disk key (the 1Password agent locked mid-session and failed agent ssh calls) and share one connection for 10 minutes (~380 ms → ~20 ms per command; agents ran 1,100+ ssh commands a month). The ssh phase links it and prepends an `Include` to the untracked `~/.ssh/config`.
- **`agents/skills/sync-main/sync-main.sh`** — `/sync-main` (the most used command, 345 runs) now runs one tested script instead of a model-driven multi-step loop (median 4 tool calls / 58 s, p90 27 calls / 14 min → one call, < 1 s). Adds `--dry-run`, and keeps any worktree a running process uses.
- **`autoMode.environment` + `cleanupPeriodDays: 90`** in `claude/settings.json` — classifier context for the user's own orgs, remotes, tailnet hosts and MCP services; transcripts kept 90 days for usage audits.
- **Working Style section in `claude/CLAUDE.md` and `pi/AGENTS.md`** (and the machine-local `~/.codex/AGENTS.md`) — the rules every project's memory relearned (finish directed work, ask with AskUserQuestion, verify before reporting, fix root causes, leave dg's processes alone).
- **Agent-safe shells** — `zshrc` skips Spaceship, autosuggestions, syntax highlighting, atuin, the tmux window hook and the eza/bat/dust/btm aliases when `CLAUDECODE=1`, so Claude Code's Bash tool gets stock `ls`/`cat`/`du`. Agent shell startup: 94 ms.
- **Read-only Bash allowlist** — `rg`, `fd`, `jq`, `head`, `tail`, `diff`, `stat` in `claude/settings.json`, so auto mode makes fewer classifier calls.
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
- **1Password SSH commit signing** — gitconfig sets `gpg.format = ssh` and points at 1Password's `op-ssh-sign`. Signing is opt-in per machine: set `commit.gpgsign = true` and `user.signingKey` in `~/.gitconfig.local`.
- **`CHANGELOG.md`** — this file.
- **Pi config tracked under `pi/`** — `pi/models.json` (lmstudio + darksaber local providers, Anthropic key via `!op read` from 1Password) and `pi/settings.json` (local-first default model) are now symlinked into `~/.pi/agent/` by the agents phase. Reproducible on a new machine; no secrets in the repo (`auth.json` stays machine-local).
- **tmux popups** — `prefix g` opens lazygit in a 90% centered popup at the current pane's path; `prefix f` opens an fzf session switcher.
- **tmux prefix indicator** — the session block in the status bar turns amber while the prefix key is armed, for visual feedback.
- **Statusline git state + color** — `claude/statusline.sh` now shows a `✱` dirty marker and `↑↓` ahead/behind counts next to the branch, and color-grades context usage (green < 50%, yellow < 80%, red ≥ 80%).
- **Battery low-charge color** — `bin/battery` flags the status-bar reading red when below 20% and unplugged.
- **Pi local-first default** — `Qwen3-Coder-30B-A3B-Instruct-MLX` is now the first lmstudio model and the default provider/model for Pi (agentic coding tuned, runs on the M5 Max).
- **Obsidian cask** — the Obsidian desktop app is now brew-managed, alongside the existing `obsidian.nvim` workflow over the `~/notes/` vault.
- **iCloud notes vault** — the `~/notes/` Obsidian vault now lives in iCloud Drive (`com~apple~CloudDocs/notes`), with `~/notes` symlinked to it. The symlinks phase links it idempotently on new machines once iCloud has synced, and never clobbers a real `~/notes` directory.
- **Markdown → Neovim, best-in-class** — a full markdown stack across the terminal and macOS. `glow` (mise) renders markdown in the terminal via a new `mdr` shell function (paged render, or no-arg cwd browser) and a `prefix m` tmux popup. nvim gains a browser preview (`markdown-preview.nvim`, `,mp`) alongside enriched inline rendering (`render-markdown.nvim` with `,mr` toggle). On macOS, `.md` files now open in nvim in a new Ghostty window: `macos/open-in-neovim.applescript` is compiled to `~/Applications/Open in Neovim.app` by `lib/macos.sh` and set as the default markdown handler via `duti` (new brew dep). Idempotent; `--check` reports handler drift.
- **tmux Pomodoro timer** — `tmux-pomodoro-plus` (tpm). `prefix p` start/pause, `P` cancel, `_` skip. The countdown is always shown in the status bar (` 🍅 --` placeholder when idle, spaced ` 🍅 25m` when running) via a new `bin/pomodoro-status` wrapper; desktop notifications are off. `prefix p` now overrides tmux's default previous-window binding.

### Changed

- **Claude Code permissions no longer skip review for commands that run code** — `git *`, `gh *`, `mise *`, `just *`, `brew *`, `xcrun *`, `xcodebuild *`, `fd *` and `atuin *` became read-only forms (an allow rule skips the auto-mode classifier, and `git -c core.fsmonitor=…`, `gh gist create --public`, `mise exec`, `xcrun python3` and `fd -x` run anything). New `deny` rules for secret files and `rg --pre`; `ask` rules for `gh gist/secret/repo edit` and for edits to the live dotfiles checkout. The eight `*&& git *` rules, which never matched, are gone.
- **`autoMode.environment` trusts less** — only `*.tail1cf291.ts.net` and the named hosts are the user's tailnet (any `*.ts.net` name could be another tailnet's public Funnel host), and wellrunpartners/AqenAI are described as shared orgs.
- **`ssh/tailnet.conf` matches 100.64.0.0/10, not all of 100.0.0.0/8** — and only this tailnet's `*.tail1cf291.ts.net` names.
- **`claude/CLAUDE.md`** — "present the options" no longer contradicts "no option menus"; scriptorium is scoped to the repos on its forge (the wellrunpartners repos use GitHub); new "one task per session" rule (also in `pi/AGENTS.md` and `~/.codex/AGENTS.md`); new "Claude Code tool use" section (Read before Edit, one git command per call in worktree-isolated agents). The scriptorium call shapes moved to the `scriptorium-session` hook, their only copy.
- **Installer** — `--check` exits 1 on any warning, and a CI install (`DOTFILES_CI=1`) fails on any warning; unknown phase names exit 64; `link()` backs up a real file or directory instead of overwriting it or nesting the link inside it; `brew bundle --no-upgrade` (an outdated formula is not drift, and installs no longer upgrade postgresql@18); mise refreshes PATH after `mise install` so the nvim plugin sync runs on a fresh machine; the mise phase installs the pre-commit hook; the tmux plugin check reads `tmux.conf`; `--snapshot --check` can fail.
- **CI** — Tier-2 also runs on push to master and weekly; it rewrites SSH GitHub URLs through `GIT_CONFIG_*` env (a `git config --global` rewrite was lost when the symlinks phase replaced `~/.gitconfig`). Tier-1 pins shellcheck 0.11.0 and shfmt 3.13.0 (the pre-commit versions) and runs `bin/lint-shell`, which finds every first-party script by shebang, plus the hook tests.
- **Scriptorium call shapes in `claude/CLAUDE.md`** — the doc taught `doc_read(path=…)` and `task_query(status="ready")`, both refused; it now shows the real shapes plus the field-name and `idempotency_key` rules behind ~900 refused calls a month.
- **Faster zsh startup (185 → 131 ms)** — fixed `HOMEBREW_PREFIX` replaces three `brew --prefix` forks; the `mise where java` block is gone (mise already exports `JAVA_HOME`); `ZSH_DISABLE_COMPFIX` skips compaudit; `typeset -U path` drops duplicate PATH entries.
- **Auto-format hooks (Claude + Pi)** — prettier now runs only from the project's own `node_modules/.bin`, never `npx --yes` (~0.6 s per edit, network fetch, and reformatted repos that do not use prettier).
- **Statusline** — one `jq` call instead of six (80 → 50 ms per refresh); project-relative path match is now quoted.

- **Tailscale moved to the `tailscale-app` cask** — was installed via the Mac App Store, which Homebrew can't see, so `brew bundle check` reported permanent drift and re-ran `brew bundle install` every time. Now brew-owned and reproducible.
- **Homebrew scope reduced** from ~30 packages to 12: only what mise can't manage or what's tightly coupled to brew (services, zsh plugin assets, system networking, GUI casks).
- **`mise install` failures are now warnings**, not fatal — downstream symlinks and config still land.
- **SSH keygen defaults to passphrase-protected key.** Typing `unencrypted` at the second prompt is required to opt into the convenience-only default.
- **macOS defaults are version-aware** via an optional `min_macos_major` arg to `set_default`. Skipped on non-Darwin (CI-friendly).
- **`AGENTS.md` is now a symlink to `CLAUDE.md`** — single source of truth, no more drift between the two.
- **Greptile submodule URL** switched from SSH to HTTPS so forkers without SSH auth can clone.
- **`README.markdown` renamed to `README.md`, and now carries a full keybinding reference** — GitHub renders `README.md` in preference to `README.markdown`, so the install/CI content was at risk of being invisible on the repo page. The new **Keybindings** section documents every tmux, Neovim, shell, and git binding this config defines, plus a file-to-ownership table for keeping it current.
- **Vendored Cloudflare skill pack refreshed** from `cloudflare/skills` (synced 2026-11-08). Adds 12 skills (`cf-cli`, `workers-development`, `workers-profiling`, `frameworks-on-cloudflare`, `nextjs-on-cloudflare`, `cloudflare-app-bootstrap`, `sandbox-stable`, `sandbox-next`, `sandbox-migrate-to-next`, `basin`, `k2`, `gateway-workers`) and rewrites the rest to retrieve current docs instead of carrying them (about 18,000 fewer lines). The new directories join the gitleaks allowlist for vendored docs.

### Removed

- `mise pip install pidev` — `pidev` no longer exists; Pi is now installed via mise's `npm:@mariozechner/pi-coding-agent` backend declared in `mise.toml`.
- Inline `brews=(…)` array in install.sh (moved to Brewfile).
- `declare -A cask_app_names` — replaced with a `case` statement compatible with stock macOS bash 3.2.

### Fixed

- **A fresh install failed, and CI passed anyway** — `brew "tldr"` is a disabled formula (now `tlrc`); `gitconfig`'s fetch-side `insteadOf` sent every HTTPS GitHub clone over SSH before a key existed (now `pushInsteadOf`); the oh-my-zsh installer replaced the linked `~/.zshrc` (now `--keep-zshrc`); install errors were only warnings.
- **pnpm ignored the 7-day release-age gate** — pnpm 12 does not read `minimum-release-age` from `rc`; `config/pnpm/config.yaml` sets `minimumReleaseAge` (verified: vite 8.3.6 locked, not the 2-day-old 8.3.8). mise gained the same gate (`minimum_release_age = "7d"`).
- **The commonplace Stop hook timed out on large transcripts** (59 times in a month at 15 s, skipping the nudge). It now scans only new bytes, with per-session state in `$TMPDIR`.
- **The status line took git's index lock on every refresh**, colliding with agents' commits ("index.lock exists"); it also ran array values from its input through `eval` and showed a false project path outside the project.
- **`auto-format.sh` looped forever on a relative path**, and both auto-format hooks ran `node_modules/.bin/prettier` from any directory above the file, including a cloned repo's committed binary or world-writable `/tmp`.
- **`lib/ssh.sh`** replaced a symlinked `~/.ssh/config` with a regular file, created `~/.ssh` as 0755, and added a second Include when one was spelled differently.
- **opencode's MCP block used `mcpServers`** (opencode reads `mcp`) and an unpinned `npx -y` server that 404s; it is now a remote MCP entry whose auth header is read from an untracked file. A zod override clears the high-severity Dependabot alert in `config/opencode`.
- **`zshrc` put `~/.opencode/bin` and `~/.bun/bin` ahead of mise**, hiding the pinned opencode and bun.
- **CHANGELOG said gitconfig sets `commit.gpgsign = true`**; signing is opt-in per machine through `~/.gitconfig.local`.
- **`sync-main.sh` deleted unmerged work** — it removed worktrees that held only untracked files, unlocked and removed locked (agent) worktrees, deleted branches whose commit subjects matched main or whose upstream was `[gone]` even with different or unpushed commits, and stashed the main checkout's uncommitted work. It now judges content (ancestor, `git cherry`, or a `git merge-tree` result equal to main), keeps locked and untracked worktrees, removes without `--force`, never stashes (checkout + `--ff-only`), and reports only removals that succeeded. `test-sync-main.sh` covers each case and runs in CI.
- **bash 3.2 `unbound variable` on cask install** — stock macOS bash doesn't support associative arrays; with `set -u` the lookup tripped on the first cask. Now uses a portable `case` statement.
- **Stale docs across `CLAUDE.md`, `AGENTS.md`, `README.markdown`** — cask list, skill inventory, mise vs Homebrew split, pi-coding-agent reference.
- **`prefix J` silently shadowed `resize-pane -D`** — `tmux.conf` bound `J` twice: once in the `H/J/K/L` resize block, then again as `join-pane` 19 lines later. tmux keeps the last binding, so resize-down had no key at all. `join-pane` moved to `prefix @`; the resize block is whole again.
- **Tier-2 CI trigger comment contradicted the job** — the header comment claimed "only on PRs to main" while the `if:` fires on any pull request or `workflow_dispatch`.
- **Stale claims in `CLAUDE.md`** — `effortLevel` (medium → high), four undeclared Claude plugins, the `Stop` hook, the vendored Cloudflare skill set, the MesloLGS Nerd Font cask, and the incomplete Pomodoro key list (`prefix e`, `prefix M-p`).
- **`pi` not on PATH after node version bump** — `pi` was installed under the old node mise install dir. Pinning it via mise's `npm:` backend in `mise.toml` makes it follow whichever node version is active.

### Security

- **`npmrc` reads the GitHub Packages token from `${NODE_AUTH_TOKEN}`** — `~/.npmrc` is a symlink to this tracked file, so a tool that saved a token to `~/.npmrc` wrote a live PAT into the public repo's working tree (it was never committed). The token now lives in the untracked `~/.bootstrap/env.sh`, and the file warns every future writer.
- Added `gitleaks` to pre-commit and CI to catch accidentally-committed secrets.
- SSH key generation now defaults to a passphrase-protected key.
- Commits/tags are signed by default via 1Password SSH-signing.
