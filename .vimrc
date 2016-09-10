let mapleader=" " 
set number
set autoindent
set expandtab
set tabstop=8
set expandtab
set shiftwidth=4
set softtabstop=4
set ignorecase
set smartcase
let python_highlight_all = 1
let g:tex_flavor='latex'

" use ctrl-c/v to copy/paste to/from clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p
" inoremap <Leader>p <C-R>+
"
" vimperator like tab new
nnoremap t :tabnew<Space>

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
Plugin 'leafgarland/typescript-vim'
Plugin 'pangloss/vim-javascript'
Plugin 'vim-latex/vim-latex'
call vundle#end()

filetype plugin indent on
syntax on
set foldmethod=syntax
