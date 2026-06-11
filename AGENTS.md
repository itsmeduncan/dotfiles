# Dotfiles

Personal dotfiles for macOS (Apple Silicon). Managed by symlinks via `install.sh`.

## Setup

1. Clone the repo and run `./install.sh`
2. The script handles everything: Homebrew (bootstrap + casks + a small set of system tools), mise (all runtimes + CLI tools, declared in `mise.toml`), symlinks, SSH key, oh-my-zsh, tpm, rustup, Neovim plugins, macOS defaults, firewall, and Claude Code config

## Structure

All files in the repo root get symlinked to `~/.<filename>` by `install.sh`.

- **Shell:** `zshrc` (primary shell config, oh-my-zsh + Spaceship), `zprofile` (env vars, PATH)
- **Git:** `gitconfig` (aliases, delta pager, modern defaults), `gitignore` (global ignores including AI tools), `gitmessage` (commit template)
- **Editor:** `config/nvim/init.lua` (Neovim primary editor, lazy.nvim + LSP), `vimrc` (legacy Vim config with vim-plug), `.editorconfig` (cross-editor formatting)
- **Terminal:** `tmux.conf` (tmux with tpm, mouse, clipboard, session restore, Ghostty terminal overrides)
- **Utilities:** `bin/weather`, `bin/battery` (custom scripts used in tmux status bar)
- **Yazi:** `config/yazi/` (keymap, theme, and yazi config — symlinked to `~/.config/yazi/`)
- **Bat:** `config/bat/config` (theme + style — symlinked to `~/.config/bat/config`)
- **Ghostty:** `config/ghostty/config` (terminal config — symlinked to `~/.config/ghostty/config`)
- **Opencode:** `config/opencode/opencode.json` (opencode CLI agent config — symlinked to `~/.config/opencode/`)
- **Shared skills:** `agents/skills/` (workflow skills shared across all AI tools — symlinked to `~/.agents/skills`, `~/.pi/agent/skills`, and `~/.claude/skills`). One git submodule (`greptile/`) provides `check-pr`; sibling repo `~/Projects/src/github.com/itsmeduncan/ai-marketing-skills/` is mounted via top-level symlinks for marketing/ops skills; the rest are local.
- **Claude Code:** `claude/CLAUDE.md`, `claude/settings.json`, `claude/agents/`, `claude/rules/`, `claude/hooks/`, `claude/statusline.sh` (`claude/skills` is a symlink → `../agents/skills`).
- **Codex / opencode:** profile-wide instructions for those tools live outside this repo (`~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`). Both consume the shared `agents/skills/` via the symlinks above.
- **Tool versions:** `mise.toml` (all language runtimes + most CLI tools, pinned — symlinked to `~/.config/mise/config.toml`)
- **Package managers (supply-chain hygiene for project-level installs):** `npmrc` (npm — min release age, no scripts), `bunfig.toml` (bun — min release age), `config/uv/uv.toml` (uv — exclude-newer), `config/pnpm/rc` (pnpm — min release age)
- **Scripts:** `bin/weather`, `bin/battery` (symlinked to `~/.dotfiles/bin/`, used in tmux status bar)
- **Other:** `gemrc`, `psqlrc`

## Key tools

- **Shell:** zsh + oh-my-zsh + Spaceship Prompt + zsh-autosuggestions + zsh-syntax-highlighting
- **Primary dependency manager:** mise — all language runtimes (Node, Python, Ruby, Go, Java, Bun) AND most CLI tools (neovim, eza, bat, ripgrep, fd, zoxide, fzf, delta, direnv, gh, lazygit, pre-commit, uv, pnpm, just, jq, yq, hyperfine, dust, bottom, tokei, awscli, terraform, opencode, swiftlint, atuin, `npm:@mariozechner/pi-coding-agent`). Versions pinned in `mise.toml` at the repo root. Upgrade with `mise upgrade --bump`.
- **Homebrew (`/opt/homebrew`):** secondary, used only for: mise itself (bootstrap), GUI casks, tmux, zsh plugin assets, postgresql, watchman, system networking tools (mosh, nmap, wget), tldr, yazi, git-absorb, cocoapods (ruby gem).
- **AI:** opencode (CLI agent), lm-studio (local LLMs)
- **Go:** GOPATH at `$HOME/Projects/`
- **Rust:** rustup (installed by `install.sh` if missing)
- **Env management:** direnv
- **Modern CLI:** eza (ls), bat (cat), ripgrep (grep), fd (find), zoxide (cd), fzf (fuzzy finder), delta (git diffs), lazygit, yazi (file manager), dust (du), bottom (top), tokei (code stats), hyperfine (benchmarks), tldr (man pages), mosh (remote shell), wget
- **Shell history:** atuin (SQLite-backed, fuzzy-searchable, per-directory filtering)
- **Dev tools:** uv (Python packaging), pnpm (Node packaging), jq/yq (JSON/YAML), watchman (file watching), just (command runner), PostgreSQL (database)
- **Mobile:** cocoapods, swiftlint (iOS); Android SDK + commandlinetools (Android)
- **Cloud & infra:** awscli, terraform, gcloud-cli (Google Cloud CLI)
- **Networking:** mosh, nmap
- **GUI apps (casks):** Ghostty, OrbStack, 1Password, Slack, Notion, Tailscale, LM Studio, gcloud-cli
- **Git workflow:** gh (GitHub CLI), pre-commit (hook framework), git-absorb (auto-fixup commits)

## Git config highlights

- `delta` as pager with side-by-side diffs
- `pull.rebase = true` — no merge commits on pull
- `push.autoSetupRemote = true` — no `-u origin` needed on first push
- `merge.conflictstyle = zdiff3` — better conflict markers
- `rerere.enabled = true` — remembers conflict resolutions
- `rebase.autosquash = true` + `updateRefs = true` — modern rebase defaults
- `diff.algorithm = histogram` — better diffs for moved code
- `fetch.prune = true` — auto-cleanup stale remote branches
- `init.defaultBranch = main`
- Aliases: `st`, `co`, `ci`, `bl`, `br`, `d`, `dp`, `dw`, `ds`, `f`, `p`, `ffm`, `l`, `lg`, `su`, `suf`, `undo`, `amend`, `wip`, `cleanup`, `absorb`

## Neovim

Primary editor (`nvim`). Config at `config/nvim/init.lua`, symlinked to `~/.config/nvim/`.

- Plugin manager: lazy.nvim (auto-bootstrapped)
- Colorscheme: jellybeans.vim
- LSP: Mason (auto-install) + native vim.lsp — pyright (Python), ts_ls (TypeScript/JS), kotlin_language_server (Kotlin), lua_ls (Lua), sourcekit (Swift via Xcode)
- Completion: blink.cmp
- Fuzzy finder: fzf-lua (`<C-p>` files, `<leader>f` grep, `<leader>b` buffers)
- Treesitter: syntax highlighting, text objects
- Git: vim-fugitive (`<leader>gs` status, `<leader>gd` diff, `<leader>gp` push), gitsigns.nvim (gutter signs, hunk staging, inline blame)
- Formatting: conform.nvim (format-on-save: ruff, prettier, stylua, swiftformat, ktlint)
- Linting: nvim-lint (async: ruff, swiftlint)
- Diagnostics: trouble.nvim (`<leader>xx` workspace, `<leader>xd` document)
- File explorer: oil.nvim (`<leader>e`, `-`)
- Motion: flash.nvim (`s` jump, `S` treesitter select)
- Bookmarks: harpoon (`<leader>a` add, `<leader>1..4` jump)
- Editing: Comment.nvim (toggle comments), nvim-surround (surround text objects)
- Status line: lualine.nvim (jellybeans theme)
- Tmux integration: vim-tmux-navigator (`C-h/j/k/l` pane navigation)
- Utilities: snacks.nvim (dashboard, notifier, indent guides, word highlight, terminal — `<leader>d` delete buffer, `<leader>tt` terminal)
- Icons: nvim-web-devicons
- Keybinding discovery: which-key.nvim
- Markdown rendering: render-markdown.nvim
- Personal notes: obsidian.nvim (Obsidian-style vault at `~/notes/`, `,ww` quick switch, `,wt` today's daily, `,wn` new, `,wf` grep, `,wb` backlinks) — plain markdown with `[[wikilinks]]` and frontmatter, ingestible by local LLMs
- Lua LSP: lazydev.nvim
- Config: `<leader>r` edit, `<leader>R` reload
- AI assistant: `nickjvandyke/opencode.nvim` (`<leader>o` to open)
- Key leader: `,`

## Tmux

Managed by tpm (tmux plugin manager). Config at `tmux.conf`.

- Plugins: tmux-resurrect (session persistence), tmux-sensible (sensible defaults), tmux-continuum (auto-restore every 15min), tmux-yank (clipboard integration)
- Ghostty terminal support: RGB color override, passthrough enabled
- Vim-style pane navigation (`C-h/j/k/l`) via vim-tmux-navigator integration
- Status bar: session name, window tabs, weather, battery, date/time
- Quick Claude Code pane: `prefix C` (30% right split)
- Vi copy mode with pbcopy integration

## AI Agent Configs

This repo holds Claude Code config and a shared skills directory. Codex and opencode read profile-wide instructions from outside the repo but consume the same shared skills.

### Claude Code (`claude/`)

Profile-wide config stored in `claude/`, symlinked to `~/.claude/` by `install.sh`.

- **`claude/CLAUDE.md`** — Profile-wide instructions (coding preferences, conventions).
- **`claude/settings.json`** — Pre-approved tool permissions, `defaultMode: auto`, status line, hooks (auto-format on Edit/Write), `effortLevel: medium`, `theme: dark-ansi`, plugins (`swift-lsp`, `frontend-design`, `superpowers`, `skill-creator`, `feature-dev`, `claude-code-setup`).
- **`claude/rules/`** — Path-scoped rules: `python.md`, `typescript.md`, `swift.md`, `kotlin.md`, `terraform.md`.
- **`claude/agents/`** — Reusable agents with tool restrictions: `review.md`, `test.md`, `debug.md`, `pr.md`, `scaffold.md`.
- **`claude/hooks/auto-format.sh`** — PostToolUse hook (ruff, prettier, swiftformat, ktlint).
- **`claude/statusline.sh`** — Status line (directory, git branch, model, context usage, rate limits).
- **`claude/skills`** — Symlink → `../agents/skills` (the shared directory below).

### Shared skills (`agents/skills/`)

The canonical skills directory shared across Claude, Codex, opencode, and pi. Symlinked into `~/.claude/skills`, `~/.agents/skills`, and `~/.pi/agent/skills` by `install.sh`. Categories:

- **Local skills** (authored in this repo): `audit`, `code-review`, `cross-platform-review`, `deep-review`, `doc-sync`, `fix-ci`, `fix-pipeline`, `release`, `sync-docs`, `sync-main`, `unstick`.
- **Vendored greptile** (`agents/skills/greptile/`, git submodule) — `check-pr` re-exposed at top level.
- **Sibling-repo marketing/ops skills** (symlinked from `~/Projects/src/github.com/itsmeduncan/ai-marketing-skills/`): `autoresearch`, `content-ops`, `conversion-ops`, `deck-generator`, `eval`, `finance-ops`, `growth-engine`, `outbound-engine`, `podcast-ops`, `revenue-intelligence`, `sales-pipeline`, `sales-playbook`, `security`, `seo-ops`, `team-ops`, `telemetry`, `x-longform-post`, `yt-competitive-analysis`.

Use `ls agents/skills/` for the live inventory.

## Conventions

- No secrets in dotfiles. Use `~/.bootstrap/env.sh` or direnv for secrets.
- AI tool artifacts (`.claude/`, `.codex/`, `.cursor/`, `.aider*`, `.env`) are globally gitignored.
- Editor is `nvim` everywhere (shell, gitconfig). `vim` and `vi` are aliased to `nvim`.
- `.editorconfig` enforces 2-space indent (4 for Python/Go/Swift/Kotlin), LF line endings, UTF-8.
- Projects live in `~/Projects/src/github.com/<org>/<repo>`.
