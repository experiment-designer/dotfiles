let mapleader=','
set number
set autoindent
set expandtab
set tabstop=8
set expandtab
set shiftwidth=4
set softtabstop=4
let python_highlight_all = 1

" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'klen/python-mode'
Plugin 'kchmck/vim-coffee-script'
Plugin 'tpope/vim-fugitive'
call vundle#end()

filetype plugin indent on
syntax on
