# Dotfiles

Personal dotfiles for macOS (Apple Silicon). Managed by symlinks via `install.sh`.

## Setup

1. Clone the repo and run `./install.sh`
2. The script handles everything: Homebrew, dependencies, symlinks, oh-my-zsh, tpm, runtimes, Neovim plugins, macOS defaults, and Claude Code config

## Structure

All files in the repo root get symlinked to `~/.<filename>` by `install.sh`.

- **Shell:** `zshrc` (primary shell config, oh-my-zsh + Spaceship), `zprofile` (env vars, PATH)
- **Git:** `gitconfig` (aliases, delta pager, modern defaults), `gitignore` (global ignores including AI tools), `gitmessage` (commit template)
- **Editor:** `config/nvim/init.lua` (Neovim primary editor, lazy.nvim + LSP), `vimrc` (legacy Vim config with vim-plug), `.editorconfig` (cross-editor formatting)
- **Terminal:** `tmux.conf` (tmux with tpm, mouse, clipboard, session restore)
- **Claude Code:** `claude/CLAUDE.md` (profile-wide instructions), `claude/settings.json` (permissions), `claude/agents/` (reusable agents)
- **Other:** `gemrc`, `psqlrc`

## Key tools

- **Shell:** zsh + oh-my-zsh + Spaceship Prompt + zsh-autosuggestions + zsh-syntax-highlighting
- **Package manager:** Homebrew (`/opt/homebrew`)
- **Version manager:** mise (manages Node, Python, Ruby, Java, and other runtimes)
- **Go:** GOPATH at `$HOME/Projects/`
- **Env management:** direnv
- **Modern CLI:** eza (ls), bat (cat), ripgrep (grep), fd (find), zoxide (cd), fzf (fuzzy finder), delta (git diffs), lazygit
- **Dev tools:** uv (Python packaging), pnpm (Node packaging), jq/yq (JSON/YAML), watchman (file watching)
- **Mobile:** cocoapods, swiftlint (iOS); Android SDK + commandlinetools (Android)
- **Git workflow:** gh (GitHub CLI), pre-commit (hook framework)

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
- Aliases: `st`, `co`, `ci`, `br`, `d`, `ds`, `f`, `p`, `ffm`, `l`, `lg`, `undo`, `amend`, `wip`, `cleanup`

## Neovim

Primary editor (`nvim`). Config at `config/nvim/init.lua`, symlinked to `~/.config/nvim/`.

- Plugin manager: lazy.nvim (auto-bootstrapped)
- LSP: pyright (Python), ts_ls (TypeScript/JS), kotlin_language_server (Kotlin), lua_ls (Lua), sourcekit (Swift via Xcode)
- Completion: blink.cmp
- Fuzzy finder: fzf-lua
- Treesitter for syntax highlighting
- Key leader: `,`

## Claude Code

Profile-wide config stored in `claude/`, symlinked to `~/.claude/` by `install.sh`.

- **`claude/CLAUDE.md`** — Profile-wide instructions (coding preferences, stack defaults, conventions). Applied to every project.
- **`claude/settings.json`** — Pre-approved tool permissions for common dev commands (git, gh, mise, uv, pnpm, npm, node, python, ruff). Includes compound command rules so git/gh are auto-allowed in chained (`&&`, `;`, `|`) commands.
- **`claude/agents/`** — Reusable agents:
  - `review.md` — Code review (bugs, security, performance, readability)
  - `test.md` — Write tests for new or changed code
  - `debug.md` — Systematically diagnose and fix bugs
  - `pr.md` — Create well-structured pull requests
  - `scaffold.md` — Bootstrap new projects with best-practice structure

## Conventions

- No secrets in dotfiles. Use `~/.bootstrap/env.sh` or direnv for secrets.
- AI tool artifacts (`.claude/`, `.cursor/`, `.aider*`, `.env`) are globally gitignored.
- Editor is `nvim` everywhere (shell, gitconfig). `vim` and `vi` are aliased to `nvim`.
- `.editorconfig` enforces 2-space indent (4 for Python/Go/Swift/Kotlin), LF line endings, UTF-8.
- Projects live in `~/Projects/src/github.com/<org>/<repo>`.
