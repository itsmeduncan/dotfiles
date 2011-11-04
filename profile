[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

CDPATH=".:~:~/Projects"

export PATH="/usr/local/bin:$PATH"

export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

source "$HOME/.git-completion.bash"

PS1="\A \[\e[28;1m\]\u@\h \[\e[0m\]\W\$(__git_ps1)\$ "

alias ls="ls -G"
alias ss="./script/server"
alias sc="./script/console"
alias unicorn="unicorn_rails -p3000"
alias bes="bundle exec rspec"
alias ber="bundle exec rake"

export NODE_PATH=/usr/local/lib/node

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi
