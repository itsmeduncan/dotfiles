# Guard: only set EDITOR if nvim is actually on PATH (install.sh symlinks zshrc
# before Homebrew packages are installed, so a mid-install shell restart would break)
command -v nvim &>/dev/null && export EDITOR='nvim' && export VISUAL='nvim'

# Agent shells: Claude Code sets CLAUDECODE=1 and snapshots this config for its
# Bash tool. Agents need stock coreutils and no prompt/ZLE widgets, so the
# human-only blocks below are skipped there.
[[ -n "$CLAUDECODE" ]] && _agent_shell=1

# Keep PATH entries unique: zprofile and this file both append to it.
typeset -U path

# A fixed prefix saves a `brew --prefix` fork on every use (Apple Silicon path).
: "${HOMEBREW_PREFIX:=/opt/homebrew}"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(brew mise direnv gh fzf zoxide uv terraform aws docker-compose)
# Skip compaudit's permission scan of fpath (~15 ms per shell). Safe on a
# single-user Mac; unset this if other users can write to the fpath dirs.
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

SPACESHIP_PROMPT_ORDER=(dir git node docker exec_time line_sep char)
SPACESHIP_PROMPT_ADD_NEWLINE=true
SPACESHIP_CHAR_SYMBOL="❯ "
SPACESHIP_DIR_TRUNC=2
SPACESHIP_GIT_STATUS_PREFIX=" ["
SPACESHIP_GIT_STATUS_SUFFIX="]"

# Low-profile context: dim, no icons, only show when relevant
SPACESHIP_NODE_PREFIX=" "
SPACESHIP_NODE_SUFFIX=""
SPACESHIP_NODE_SYMBOL=""
SPACESHIP_NODE_COLOR="240"
SPACESHIP_NODE_DEFAULT_VERSION=""

SPACESHIP_DOCKER_PREFIX=" "
SPACESHIP_DOCKER_SUFFIX=""
SPACESHIP_DOCKER_SYMBOL="d:"
SPACESHIP_DOCKER_COLOR="240"
SPACESHIP_DOCKER_VERBOSE=false
SPACESHIP_DOCKER_CONTEXT_SHOW=false

SPACESHIP_EXEC_TIME_PREFIX=" "
SPACESHIP_EXEC_TIME_SUFFIX=""
SPACESHIP_EXEC_TIME_COLOR="240"
SPACESHIP_EXEC_TIME_ELAPSED=5
SPACESHIP_EXEC_TIME_SHOW=true

if (( ! _agent_shell )); then
  source "$HOMEBREW_PREFIX/opt/spaceship/spaceship.zsh"
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

setopt auto_cd
cdpath=(~ ~/Projects/src/github.com ~/Projects)

setopt autopushd

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
# JAVA_HOME comes from mise's java tool on activation; no `mise where` fork here.

# fzf customizations (plugin handles init and FZF_DEFAULT_COMMAND)
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 {}'"

# Update tmux window name with project:branch (throttled to avoid git latency on slow FS)
_tmux_window_name() {
  [[ -n "$TMUX" ]] || return
  # Skip if PWD hasn't changed since last run
  [[ "$PWD" == "$_TMUX_LAST_PWD" ]] && return
  _TMUX_LAST_PWD="$PWD"

  local repo branch name
  if repo=$(git rev-parse --show-toplevel 2>/dev/null); then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    name="${repo:t}${branch:+:$branch}"
  else
    name="${PWD:t}"
  fi
  tmux rename-window "$name" 2>/dev/null
}

if (( ! _agent_shell )); then
  # atuin - shell history
  eval "$(atuin init zsh)"
  add-zsh-hook precmd _tmux_window_name

  # These replace coreutils with tools that take different flags and print
  # different output, so agents keep the stock commands.
  alias ls="eza"
  alias ll="eza -la --git"
  alias cat="bat --paging=never"
  alias tree="eza --tree"
  alias top="btm"
  alias du="dust"
fi

alias lg="lazygit"
alias dc="docker compose"
# zoxide (already installed) handles this better: `z p` auto-learns the path
alias p="cd ~/Projects/src/github.com"

[[ -s "$HOME/.bootstrap/env.sh" ]] && . "$HOME/.bootstrap/env.sh"

export PATH="$HOME/.local/bin:$PATH"

# yazi - cd to last directory on exit
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

alias g="git"
alias vi="nvim"
alias vim="nvim"

# Markdown: `mdr file.md` renders it paged with glow; `mdr` with no args opens
# glow's file browser scoped to the current dir. (Not `md` — that's oh-my-zsh's
# `mkdir -p`.) Editing is still `vim file.md` (render-markdown.nvim styles it
# inline, `,mr` toggle); a full browser preview is `,mp`.
mdr() {
  if [ "$#" -eq 0 ]; then
    glow
  else
    glow -p "$@"
  fi
}

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# bun completions
[ -s "/Users/duncan/.bun/_bun" ] && source "/Users/duncan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
