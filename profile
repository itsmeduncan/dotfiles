export GOPATH=$HOME/Projects/
export PATH="/usr/local/sbin:/usr/local/bin:$GOPATH/bin:/usr/local/share/npm/bin:$PATH"

CDPATH=".:~:~/Projects:$GOPATH/src/github.com/shopkeep:$GOPATH/src/github.com/itsmeduncan:$GOPATH/src/github.com/madewithglimpse"
PS1='\A \W$(__git_ps1 "<%s>") » '

export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export EDITOR='atom -w'
export VISUAL='atom -w'

export DOCKER_HOST=tcp://192.168.59.103:2376
export DOCKER_CERT_PATH=/Users/itsmeduncan/.boot2docker/certs/boot2docker-vm
export DOCKER_TLS_VERIFY=1

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

export NODE_PATH=$NODE_PATH:/usr/local/lib/node

complete -C aws_completer aws

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

export PATH="$PATH:$HOME/.rvm/bin"
