export EDITOR='nvim'
export VISUAL='nvim'

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
source "$(brew --prefix)/opt/spaceship/spaceship.zsh"
plugins=(git brew)
source $ZSH/oh-my-zsh.sh

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

setopt auto_cd
cdpath=(~ ~/Projects/src/github.com ~/Projects)

setopt autopushd

eval "$(mise activate zsh)"

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
export JAVA_HOME=$(mise where java 2>/dev/null)

eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"

# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 {}'"
source <(fzf --zsh)

# Update tmux window name with project:branch
_tmux_window_name() {
  [[ -n "$TMUX" ]] || return
  local repo branch name
  if repo=$(git rev-parse --show-toplevel 2>/dev/null); then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    name="${repo:t}${branch:+:$branch}"
  else
    name="${PWD:t}"
  fi
  tmux rename-window "$name"
}
add-zsh-hook precmd _tmux_window_name

alias ls="eza"
alias ll="eza -la --git"
alias cat="bat --paging=never"
alias tree="eza --tree"
alias lg="lazygit"
alias dc="docker compose"
alias p="cd ~/Projects/src/github.com"

[[ -s "$HOME/.bootstrap/env.sh" ]] && . "$HOME/.bootstrap/env.sh"

export PATH="$HOME/.local/bin:$PATH"

alias g="git"
alias vi="nvim"
alias vim="nvim"
