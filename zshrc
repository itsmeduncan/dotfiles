# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
source /opt/homebrew/opt/spaceship/spaceship.zsh
plugins=(git brew)
source $ZSH/oh-my-zsh.sh

setopt auto_cd
cdpath=(~ ~/Projects/src/github.com ~/Projects)

setopt autopushd

eval "$(mise activate zsh)"

eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

alias ls="eza"
alias ll="eza -la --git"
alias cat="bat --paging=never"

[[ -s "$HOME/.bootstrap/env.sh" ]] && . "$HOME/.bootstrap/env.sh"
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/buildops-dgrazier/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/.local/bin:$PATH"
