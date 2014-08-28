export GOPATH=$HOME/Projects/Go
export PATH="/usr/local/sbin:/usr/local/bin:$GOPATH/bin:/usr/local/share/npm/bin:$PATH"

CDPATH=".:~:~/Projects:~/Projects/Shopkeep:~/Projects/Actuator:$GOPATH/src/github.com/shopkeep:$GOPATH/src/github.com/itsmeduncan"
PS1='\[\e[90m\A\e[0m\] \[\e[32m\W\e[0m\]$(__git_ps1 "‹\e[100m%s\e[0m›") » '

export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export EDITOR='atom -w'
export VISUAL='atom -w'

source "$HOME/.git-completion.bash"

alias ls="ls -G"
alias ll="ls -alhFG"
alias ss='bundle exec rails s'
alias sc='bundle exec rails c'
alias bes='bundle exec rspec'
alias ber='bundle exec rake'
alias be='bundle exec'
alias mou="open -a Mou"
alias clean='git br --merged | grep -v "\*" | xargs -n 1 git branch -d'
alias prune='git remote prune origin'

export NODE_PATH=/usr/local/lib/node

complete -C aws_completer aws

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi
[[ -s /Users/duncan/.nvm/nvm.sh ]] && . /Users/duncan/.nvm/nvm.sh # This loads NVM
