# Guard: only set EDITOR if nvim is actually on PATH (install.sh symlinks zshrc
# before Homebrew packages are installed, so a mid-install shell restart would break)
command -v nvim &>/dev/null && export EDITOR='nvim' && export VISUAL='nvim'

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(brew mise direnv gh fzf zoxide uv terraform aws docker-compose)
source $ZSH/oh-my-zsh.sh
source "$(brew --prefix)/opt/spaceship/spaceship.zsh"

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

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

setopt auto_cd
cdpath=(~ ~/Projects/src/github.com ~/Projects)

setopt autopushd

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
# Only set JAVA_HOME if mise has java installed (avoids empty-string pitfalls)
if mise where java >/dev/null 2>&1; then
  export JAVA_HOME=$(mise where java)
fi

# fzf customizations (plugin handles init and FZF_DEFAULT_COMMAND)
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 {}'"

# atuin - shell history
eval "$(atuin init zsh)"

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
add-zsh-hook precmd _tmux_window_name

alias ls="eza"
alias ll="eza -la --git"
alias cat="bat --paging=never"
alias tree="eza --tree"
alias lg="lazygit"
alias top="btm"
alias du="dust"
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

# Markdown: `md file.md` renders it paged with glow; `md` with no args opens
# glow's file browser scoped to the current dir. Editing is still `vim file.md`
# (render-markdown.nvim styles it inline); a full browser preview is <leader>mp.
md() {
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
