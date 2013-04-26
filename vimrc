" Use Vim settings
set nocompatible
filetype off

" Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

" Encoding
set encoding=utf-8

" Syntax highlight
syntax on

" Use the BusyBee theme
colo BusyBee
" colo wombat " Wombat is pretty too

" Highlight search pattern
set hlsearch

" Show a short message
set shortmess=a

" Show line numbers
set number
set numberwidth=3

" Always show the status line
set laststatus=2

" Fancy backspacing
set backspace=indent,eol,start

" 2 spaces for indenting
set shiftwidth=2

" 2 stops
set tabstop=2

" Spaces instead of tabs
set expandtab

" Autotab
set autoindent

" Do not backup
set nobackup
set nowritebackup
set noswapfile
set backupdir=$HOME/.vim/backup
set backupcopy=yes
set backupskip=/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*
set directory=$HOME/.vim/swap,$HOME/tmp,.

" Always show the cursor
set ruler

" Show partial commands
set showcmd

" Incremental searching
set incsearch

" Visual whitespace
set list
set listchars=tab:\ \ ,trail:.

" Ignore case, and use smartcase
set ignorecase
set smartcase

" Intelligent search
set scs

" Show matching brackets
set showmatch
set mat=5

" No wrap
set nowrap

" Don't lazy redraw
set nolazyredraw

" Tell us about changes
set report=0

" Don't jump to start of the line when scrolling
set nostartofline

" Silence!
set visualbell

" No tabs
set nosmarttab

" Virtual edit in visual block
set virtualedit=block

" Window splitting
set splitbelow
set splitright

" ---
" Bundles
" ---
Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'rails.vim'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-haml'
Bundle 'taglist.vim'
Bundle 'plasticboy/vim-markdown'
Bundle 'kchmck/vim-coffee-script'

filetype plugin indent on
" ---
" Mappings
" ---
let mapleader=","

" ---
"  CTags Tag list
" ---
let Tlist_WinWidth = 50
map <F4> :TlistToggle<CR>
map <C-P> :!/usr/local/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" ---
" FuzzyFinder
" ---
map <leader>t :FufFile<CR>

" ---
" Rspec
" ---
" Run the entire file
map <F5> :! bundle exec rspec %<CR>

" Run the current context
map <F6> :! bundle exec rspec %:<C-r>=line('.')<CR>

autocmd Filetype gitcommit setlocal spell textwidth=72
