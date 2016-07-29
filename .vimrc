let mapleader=','
set number
set autoindent
set expandtab
let python_highlight_all = 1

" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'tpope/vim-haml'
Plugin 'scrooloose/nerdtree'
Plugin 'klen/python-mode'
Plugin 'kchmck/vim-coffee-script'
call vundle#end()

filetype plugin indent on
syntax on
