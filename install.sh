#!/bin/bash

files=(gemrc git-completion.bash gitconfig gitignore gitmessage profile psqlrc tmux.conf vimrc zprofile zshrc)

for file in "${files[@]}"
do
 	ln -sf `pwd`/$file $HOME/.$file
done
