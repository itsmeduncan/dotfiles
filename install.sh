#!/bin/bash

files=(atom gemrc git-completion.bash gitconfig gitignore gitmessage oh-my-zsh profile tmux.conf vimrc zshrc)

for file in "${files[@]}"
do
 	ln -sf `pwd`/$file $HOME/.$file
done
