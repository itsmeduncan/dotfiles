[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

CDPATH=".:~:~/Projects:~/Projects/ShopKeep:~/Projects/Go"

export GOPATH=$HOME/Projects/Go

export PATH="/usr/local/sbin:/usr/local/bin:$GOPATH/bin:/usr/local/share/npm/bin:$PATH"

export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

export EDITOR='subl -w'
export VISUAL='subl -w'

export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

source "$HOME/.git-completion.bash"

PS1="\A \[\e[0m\]\W\$(__git_ps1)\$ "

alias ls="ls -G"
alias ll="ls -alFG"
alias ss="bundle exec rails s"
alias sc="bundle exec rails c"
alias bes="bundle exec rspec"
alias ber="bundle exec rake"
alias be="bundle exec"
alias mou="open -a Mou"

alias git=hub

export NODE_PATH=/usr/local/lib/node

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi
[[ -s /Users/duncan/.nvm/nvm.sh ]] && . /Users/duncan/.nvm/nvm.sh # This loads NVM

