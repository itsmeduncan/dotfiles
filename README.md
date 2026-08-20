# Dotfiles

Personal dotfiles for macOS (Apple Silicon). Jump to [Keybindings](#keybindings) for every
shortcut this config defines. See [CHANGELOG.md](CHANGELOG.md) for notable changes and
[CLAUDE.md](CLAUDE.md) for architecture and tooling rationale.

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

- **brew** — install [Homebrew](https://brew.sh) if missing, then sync the [`Brewfile`](Brewfile): a slim set of things mise can't manage (tmux, postgresql@18, watchman, zsh plugins, mosh/nmap/wget, tldr, yazi, git-absorb, cocoapods) plus GUI casks (Ghostty, OrbStack, 1Password + CLI, Slack, Notion, Tailscale, LM Studio, gcloud-cli, MesloLGS Nerd Font)
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
- **Tier-2** (macOS, any pull request or manual `workflow_dispatch`): `./install.sh --dry-run`, then a real end-to-end install on a clean runner, then `./install.sh --check`

Pre-commit hooks (`.pre-commit-config.yaml`) run the same linters locally: `pre-commit install` once, then they fire on every commit.

## Agent skills

Global cross-agent skills live in `agents/skills/`.

Claude consumes them through `claude/skills -> ../agents/skills`.
Codex discovers them through `~/.agents/skills`. OpenCode is configured
with `skills.paths` in `config/opencode/opencode.json`. Pi gets the
same tree at `~/.pi/agent/skills` for agents that know to inspect a
local skills directory.

---

## Keybindings

Every key combo, alias, and shortcut this config defines, and which file defines it.
Bindings below were verified against a live tmux server and the current config files.

### Cheat sheet

The eight you'll reach for most:

| Keys                    | Does                                                                      |
| ----------------------- | ------------------------------------------------------------------------- |
| `C-b p`                 | Start / pause the Pomodoro timer (countdown lives in the tmux status bar) |
| `C-b g`                 | lazygit, full-screen popup, at the current pane's path                    |
| `C-b C`                 | Split off a 30% Claude Code pane on the right                             |
| `C-h` `C-j` `C-k` `C-l` | Move between panes _and_ nvim splits — no prefix, one muscle memory       |
| `,f` (nvim)             | Live grep the project                                                     |
| `C-p` (nvim)            | Fuzzy-find files                                                          |
| `C-r` (shell)           | atuin history search                                                      |
| `y` (shell)             | yazi file manager; exits into whatever directory you browsed to           |

---

### tmux

Defined in [`tmux.conf`](tmux.conf). **Prefix is the default `C-b`** — it is not remapped.

Notation: `C-b |` means press `C-b`, release, then `|`. Bindings marked **no prefix**
are pressed directly. `-r` bindings repeat: hold the prefix once, then tap the key.

#### Panes and windows

| Keys                          | Action                                                                                                                            |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `C-b \|`                      | Split vertically (new pane on the right), in the current path                                                                     |
| `C-b -`                       | Split horizontally (new pane below), in the current path                                                                          |
| `C-b c`                       | New window, in the current path                                                                                                   |
| `C-b C`                       | New 30% right-hand pane — the Claude Code split                                                                                   |
| `C-b S`                       | Break the current pane out into its own window                                                                                    |
| `C-b @`                       | Join pane 2 into window 1 as a horizontal split                                                                                   |
| `C-b r`                       | Reload `~/.tmux.conf`                                                                                                             |
| `C-h` / `C-j` / `C-k` / `C-l` | **No prefix.** Move pane left/down/up/right — passes through to Neovim when a vim-like process owns the pane (vim-tmux-navigator) |
| `M-←` `M-→` `M-↑` `M-↓`       | **No prefix.** Move pane by arrow                                                                                                 |
| `M-1` … `M-5`                 | **No prefix.** Jump to window 1–5                                                                                                 |
| `C-b H/J/K/L`                 | Resize pane left / down / up / right by 5 cells (repeatable)                                                                      |

`|` and `-` replace the default `%` and `"`, which are unbound. New splits and
windows inherit the current pane's working directory rather than starting at `$HOME`.

#### Popups

Each opens centered over the current pane and closes on exit.

| Keys    | Popup                                                      | Size      |
| ------- | ---------------------------------------------------------- | --------- |
| `C-b g` | lazygit, at the current pane's path                        | 90% × 90% |
| `C-b f` | fzf session switcher — pick a session, switch to it        | 40% × 40% |
| `C-b m` | `glow` markdown browser, scoped to the current pane's path | 80% × 80% |

`C-b f` and `C-b m` override tmux's defaults (`find-window` and `mark-pane`).

#### Pomodoro

From [`tmux-pomodoro-plus`](https://github.com/olimorris/tmux-pomodoro-plus). Desktop
notifications are **off** by design — the countdown is always visible in the status
bar instead, rendered by [`bin/pomodoro-status`](bin/pomodoro-status), which shows a
dim ` 🍅 --` placeholder when no timer is running.

| Keys      | Action                                                   |
| --------- | -------------------------------------------------------- |
| `C-b p`   | Toggle — start a Pomodoro, or pause/resume a running one |
| `C-b P`   | Cancel the current Pomodoro or break                     |
| `C-b _`   | Skip to the next interval                                |
| `C-b e`   | Restart the current Pomodoro                             |
| `C-b C-p` | Open the Pomodoro menu                                   |
| `C-b M-p` | Set a custom timer duration                              |

Plugin defaults are unchanged: **25 min** work, **5 min** break, **4 intervals**,
then a **25 min** long break.

> `C-b p` overrides tmux's default `previous-window`. Use `C-b M-1`…`M-5` or
> `C-b n` / `C-b l` to move between windows instead.

#### Copy mode

vi keys (`setw -g mode-keys vi`). Enter with `C-b [`, or just scroll — the mouse is on.

| Keys        | Action                                                              |
| ----------- | ------------------------------------------------------------------- |
| `v`         | Begin selection                                                     |
| `y`         | Copy selection to the macOS clipboard (`pbcopy`) and exit copy mode |
| `C-h/j/k/l` | Change pane without leaving copy mode                               |
| `q`         | Exit copy mode                                                      |

#### Status bar

Top-positioned, refreshed every 30s: session name → window tabs → Pomodoro countdown →
weather → battery → date/time. The session block **turns amber while the prefix is
armed**, so you can see whether `C-b` registered. Weather and battery come from
[`bin/weather`](bin/weather) and [`bin/battery`](bin/battery); battery goes red when low.

Sessions auto-save every 15 minutes and restore on boot (tmux-resurrect +
tmux-continuum). The window name tracks `repo:branch` automatically via a zsh
`precmd` hook.

---

### Neovim

Defined in [`config/nvim/init.lua`](config/nvim/init.lua). **Leader is `,`**
(both `mapleader` and `maplocalleader`).

Press `,` and pause — [which-key](https://github.com/folke/which-key.nvim) pops up
the available continuations, grouped as `g` git, `h` hunks, `x` diagnostics,
`c` code, `t` toggle.

#### Files, search, buffers

| Keys        | Action                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------ |
| `C-p`       | Fuzzy-find files (fzf-lua)                                                                                   |
| `,f`        | Live grep the project                                                                                        |
| `,b`        | Switch buffers                                                                                               |
| `,e` or `-` | File explorer at the current file's directory (oil.nvim — edit the buffer like text to rename/create/delete) |
| `[b` / `]b` | Previous / next buffer                                                                                       |
| `,d`        | Delete the buffer, keeping the window layout (Snacks)                                                        |
| `,a`        | Add the current file to Harpoon                                                                              |
| `,1` … `,4` | Jump to Harpoon file 1–4                                                                                     |

#### Motion and editing

| Keys                 | Action                                                           |
| -------------------- | ---------------------------------------------------------------- |
| `s`                  | Flash jump — type a couple of characters, then the label         |
| `S`                  | Flash Treesitter — select expanding syntax nodes                 |
| `jk`                 | Escape from insert mode                                          |
| `;`                  | `:` — command mode without the shift                             |
| `C-n`                | Clear search highlight                                           |
| `gc` / `gcc`         | Toggle comment (operator / current line, Comment.nvim)           |
| `ys` / `cs` / `ds`   | Add / change / delete surround (nvim-surround)                   |
| `x` `c` `p` (visual) | Delete / change / paste **without clobbering the yank register** |

#### LSP

Bound on `LspAttach`, so they exist only in buffers with a language server.

| Keys        | Action                          |
| ----------- | ------------------------------- |
| `gd`        | Go to definition                |
| `gr`        | References                      |
| `K`         | Hover docs                      |
| `,ca`       | Code action                     |
| `,rn`       | Rename symbol                   |
| `[d` / `]d` | Previous / next diagnostic      |
| `,xx`       | Workspace diagnostics (Trouble) |
| `,xd`       | Document diagnostics (Trouble)  |

Servers auto-install via Mason: pyright, ts_ls, kotlin_language_server, lua_ls, and
sourcekit (Swift, via Xcode). Format-on-save runs through conform.nvim
(ruff / prettier / stylua / swiftformat / ktlint); linting is async via nvim-lint.

#### Git

| Keys        | Action                                   |
| ----------- | ---------------------------------------- |
| `,gs`       | Git status (fugitive)                    |
| `,gd`       | Git diff split                           |
| `,gp`       | Git push                                 |
| `,gf`       | Close the fugitive diff split and unfold |
| `]c` / `[c` | Next / previous hunk (gitsigns)          |
| `,hs`       | Stage hunk                               |
| `,hu`       | Undo stage hunk                          |
| `,hp`       | Preview hunk                             |
| `,tb`       | Toggle inline blame for the current line |

#### Markdown and notes

| Keys  | Action                                                                        |
| ----- | ----------------------------------------------------------------------------- |
| `,mr` | Toggle inline markdown rendering (render-markdown.nvim) — markdown files only |
| `,mp` | Toggle live browser preview with synced scroll — markdown files only          |
| `,ww` | Quick-switch between notes in `~/notes/`                                      |
| `,wt` | Open today's daily note (`~/notes/daily/YYYY-MM-DD.md`)                       |
| `,wn` | New note                                                                      |
| `,wf` | Grep the vault                                                                |
| `,wb` | Backlinks to the current note                                                 |
| `,wo` | Open the current note in the Obsidian app                                     |

#### Misc

| Keys  | Action                   |
| ----- | ------------------------ |
| `,tt` | Toggle terminal (Snacks) |
| `,o`  | Open OpenCode            |
| `,r`  | Edit `init.lua`          |
| `,R`  | Reload `init.lua`        |

---

### Shell

Defined in [`zshrc`](zshrc) — zsh + oh-my-zsh + Spaceship prompt.

#### Interactive keys

| Keys        | Action                                                                   |
| ----------- | ------------------------------------------------------------------------ |
| `C-r`       | atuin — fuzzy, SQLite-backed history search with per-directory filtering |
| `C-t`       | fzf file picker, previewed with `bat`                                    |
| `M-c`       | fzf directory jump (`fd`-powered), previewed with `eza --tree`           |
| `→` / `End` | Accept the zsh-autosuggestions completion                                |

#### Aliases and functions

| Command              | Runs                                                                                    |
| -------------------- | --------------------------------------------------------------------------------------- |
| `ls` / `ll` / `tree` | `eza`, `eza -la --git`, `eza --tree`                                                    |
| `cat`                | `bat --paging=never`                                                                    |
| `top`                | `btm` (bottom)                                                                          |
| `du`                 | `dust`                                                                                  |
| `g`                  | `git`                                                                                   |
| `vi` / `vim`         | `nvim`                                                                                  |
| `lg`                 | `lazygit`                                                                               |
| `dc`                 | `docker compose`                                                                        |
| `p`                  | `cd ~/Projects/src/github.com`                                                          |
| `y`                  | yazi — **and cds the shell into the directory you exit from**                           |
| `mdr [file]`         | Render markdown with `glow` — paged with a file argument, directory browser without one |
| `z <partial>`        | zoxide — jump to a frecent directory                                                    |

`md` is deliberately _not_ markdown — it stays oh-my-zsh's `mkdir -p`.
`auto_cd` is on, so a bare directory name cds into it, and `cdpath` covers
`~`, `~/Projects`, and `~/Projects/src/github.com`.

#### Git aliases

Defined in [`gitconfig`](gitconfig). Use as `git <alias>` (or `g <alias>`).

| Alias                     | Expands to                                                                                            |
| ------------------------- | ----------------------------------------------------------------------------------------------------- |
| `st`                      | `status -sb`                                                                                          |
| `co` / `ci` / `br` / `bl` | `checkout` / `commit` / `branch` / `blame`                                                            |
| `d` / `ds` / `dw` / `dp`  | `diff` / `diff --staged` / `--word-diff` / no-pager diff                                              |
| `l` / `lg`                | `log --date=human` / one-line graph log, last 20                                                      |
| `f`                       | `fetch -p` (prune)                                                                                    |
| `p`                       | `push`                                                                                                |
| `ffm`                     | `merge --ff-only`                                                                                     |
| `undo`                    | `reset --soft HEAD~1` — uncommit, keep the changes staged                                             |
| `amend`                   | `commit --amend --no-edit`                                                                            |
| `wip`                     | `add -u && commit -m 'wip'` — **tracked files only**, so it can't sweep up secrets or build artifacts |
| `absorb`                  | `git absorb --and-rebase` — auto-fixup into the right commits                                         |
| `cleanup`                 | Delete local branches already merged into `main`                                                      |
| `su` / `suf`              | `submodule update --init --recursive` (`--force`)                                                     |

Because `pull.rebase`, `push.autoSetupRemote`, `rebase.autosquash`, and
`fetch.prune` are all on, `git pull` never makes a merge commit and first-push
never needs `-u origin`.

---

### macOS

| Action                        | Behavior                                                                                                                                                                                          |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Open any `.md` file in Finder | Opens in Neovim in a **new Ghostty window**, via `~/Applications/Open in Neovim.app` (compiled from [`macos/open-in-neovim.applescript`](macos/open-in-neovim.applescript), wired up with `duti`) |
| `⌥` in the terminal           | Sends Alt/Meta — [`config/ghostty/config`](config/ghostty/config) sets `macos-option-as-alt = true`, which is what makes tmux's `M-1`…`M-5` and fzf's `M-c` work                                  |

Ghostty and yazi otherwise run on their default keymaps — neither config
overrides any bindings.

---

### Where bindings live

| File                                                 | Owns                                                                          |
| ---------------------------------------------------- | ----------------------------------------------------------------------------- |
| [`tmux.conf`](tmux.conf)                             | tmux prefix bindings, pane navigation, popups, copy mode, plugin config       |
| [`config/nvim/init.lua`](config/nvim/init.lua)       | Every Neovim mapping, including per-plugin `keys` tables and `LspAttach` maps |
| [`zshrc`](zshrc)                                     | Aliases, shell functions, fzf env, oh-my-zsh plugin list                      |
| [`gitconfig`](gitconfig)                             | Git aliases and workflow defaults                                             |
| [`config/ghostty/config`](config/ghostty/config)     | Terminal-level key behavior (`macos-option-as-alt`)                           |
| [`config/yazi/keymap.toml`](config/yazi/keymap.toml) | Empty — yazi runs on defaults                                                 |

Adding a binding? Add it to the owning file **and** to the matching table here.
