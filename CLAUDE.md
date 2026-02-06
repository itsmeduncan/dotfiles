# Dotfiles

Personal dotfiles for macOS (Apple Silicon). Managed by symlinks via `install.sh`.

## Setup

1. Clone the repo and run `./install.sh`
2. The script handles everything: Homebrew, dependencies, symlinks, oh-my-zsh, and tpm
3. Post-install: set up runtimes with `mise use -g node@lts python@3 ruby@3`

## Structure

All files in the repo root get symlinked to `~/.<filename>` by `install.sh`.

- **Shell:** `zshrc` (primary shell config, oh-my-zsh + Spaceship), `zprofile` (env vars, PATH), `profile` (bash fallback)
- **Git:** `gitconfig` (aliases, delta pager, modern defaults), `gitignore` (global ignores including AI tools), `gitmessage` (commit template)
- **Editor:** `vimrc` (Vim config with Vundle), `.editorconfig` (cross-editor formatting)
- **Terminal:** `tmux.conf` (tmux with tpm, mouse, clipboard support)
- **Other:** `gemrc`, `psqlrc`

## Key tools

- **Shell:** zsh + oh-my-zsh + Spaceship Prompt
- **Package manager:** Homebrew (`/opt/homebrew`)
- **Version manager:** mise (manages Node, Python, Ruby, and other runtimes)
- **Go:** GOPATH at `$HOME/Projects/`
- **Env management:** direnv
- **Modern CLI:** eza (ls), bat (cat), ripgrep (grep), fd (find), zoxide (cd), fzf (fuzzy finder), delta (git diffs)
- **Git workflow:** gh (GitHub CLI), pre-commit (hook framework)

## Git config highlights

- `delta` as pager with side-by-side diffs
- `pull.rebase = true` — no merge commits on pull
- `merge.conflictstyle = zdiff3` — better conflict markers
- `rerere.enabled = true` — remembers conflict resolutions
- `diff.algorithm = histogram` — better diffs for moved code
- `fetch.prune = true` — auto-cleanup stale remote branches
- Aliases: `st`, `co`, `ci`, `br`, `d`, `ds`, `f`, `p`, `ffm`, `l`

## Conventions

- No secrets in dotfiles. Use `~/.bootstrap/env.sh` or direnv for secrets.
- AI tool artifacts (`.claude/`, `.cursor/`, `.aider*`, `.env`) are globally gitignored.
- Editor is `code` (VS Code) in profile, `vim` in gitconfig.
- `.editorconfig` enforces 2-space indent (4 for Python/Go), LF line endings, UTF-8.
