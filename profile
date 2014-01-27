export GOPATH=$HOME/Projects/Go
export PATH="/usr/local/sbin:/usr/local/bin:$GOPATH/bin:/usr/local/share/npm/bin:$PATH"

CDPATH=".:~:~/Projects:~/Projects/Shopkeep:$GOPATH/src/github.com/shopkeep"

export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

export EDITOR='subl -w'
export VISUAL='subl -w'

export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

source "$HOME/.git-completion.bash"

PS1='\[\e[90m\A\e[0m\] \[\e[32m\W\e[0m\]$(__git_ps1 "‹\e[100m%s\e[0m›") » '

alias ls="ls -G"
alias ll="ls -alhFG"
alias ss="bundle exec rails s"
alias sc="bundle exec rails c"
alias bes="bundle exec rspec"
alias ber="bundle exec rake"
alias be="bundle exec"
alias mou="open -a Mou"

export NODE_PATH=/usr/local/lib/node

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi
[[ -s /Users/duncan/.nvm/nvm.sh ]] && . /Users/duncan/.nvm/nvm.sh # This loads NVM
