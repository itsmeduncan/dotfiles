# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
source "$(brew --prefix)/opt/spaceship/spaceship.zsh"
plugins=(git brew)
source $ZSH/oh-my-zsh.sh

setopt auto_cd
cdpath=(~ ~/Projects/src/github.com ~/Projects)

setopt autopushd

eval "$(mise activate zsh)"

eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
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

[[ -s "$HOME/.bootstrap/env.sh" ]] && . "$HOME/.bootstrap/env.sh"
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/buildops-dgrazier/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
