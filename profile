[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

CDPATH=".:~:~/Projects"

export PATH="/usr/local/sbin:/usr/local/bin:$PATH"

export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

export EDITOR=subl
export VISUAL=subl

source "$HOME/.git-completion.bash"

PS1="\A \[\e[0m\]\W\$(__git_ps1)\$ "

alias ls="ls -G"
alias ss="bundle exec rails s"
alias sc="bundle exec rails c"
alias bes="bundle exec rspec"
alias ber="bundle exec rake"

alias git=hub

export NODE_PATH=/usr/local/lib/node

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi
