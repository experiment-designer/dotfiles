let mapleader=" " 
set number
set autoindent
set expandtab
set tabstop=8
set shiftwidth=4
set softtabstop=4
set ignorecase
set smartcase

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set laststatus=2

let g:tex_flavor='latex'

" Replace all
noremap <Leader>/ :%s/
vnoremap <Leader>/ :s/\%V

" latex
let g:vimtex_compiler_latexmk = {'callback' : 0}

" use ctrl-c/v to copy/paste to/from clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p
" inoremap <Leader>p <C-R>+
"
" vimperator like tab new
nnoremap t :tabnew<Space>

" switch between windows easily
nnoremap <C-l> <C-w>l
nnoremap <C-k> <C-w>k
nnoremap <C-j> <C-w>j
nnoremap <C-h> <C-w>h

" Pathogen load
filetype off

" Highlight search results
set incsearch

" Ignore dist and build folders
set wildignore+=*/dist*/**,*/target/**,*/build/**

" Ignore libs
set wildignore+=*/lib/**,*/_3rd_party_/**,*/node_modules/**,*/bower_components/**

" Ignore images, pdfs, and font files
set wildignore+=*.png,*.PNG,*.jpg,*.jpeg,*.JPG,*.JPEG,*.pdf
set wildignore+=*.ttf,*.otf,*.woff,*.woff2,*.eot

" Ignore compiled files
set wildignore+=*.class
let g:basewildignore=&wildignore

" Command-T settings
let g:CommandTMaxFiles=50000
let g:CommandTTraverseSCM='pwd'

" Solves some weird insert mode bug
set backspace=indent,eol,start

" YCM
let g:ycm_confirm_extra_conf=0
let g:ycm_autoclose_preview_window_after_completion=1
" After 2 chars, autocomplete
let g:ycm_semantic_triggers = {
            \   'python': [ 're!\w{2}' ]
            \ }



" ALE
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %code%: %s [%severity%]'

" Pymode
" let g:pymode_debug = 1

" let g:pymode_python = 'python3'
" let g:pymode_breakpoint_cmd = 'import ipdb; ipdb.set_trace()'
" let g:pymode_breakpoint_bind = '<Leader>d'
" let g:pymode_folding = 1
" let g:pymode_lint_checkers = ['pylint', 'pep8', 'mccabe', 'pep257', 'pyflakes']
" let g:pymode_virtualenv = 1
" let g:pymode_rope = 0
" let g:pymode_rope_completion = 0
" let g:pymode_rope_complete_on_dot = 0

" Close quickfix windows if only window left
aug QFClose
  au!
  au WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif
aug END

call pathogen#infect()
call pathogen#helptags()
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
" Plugin 'klen/python-mode'
Plugin 'rking/ag.vim'
Plugin 'Konfekt/FastFold'
" Plugin 'scrooloose/syntastic'
Plugin 'Valloric/YouCompleteMe'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-commentary'
" Plugin 'vim-latex/vim-latex'
Plugin 'lervag/vimtex'
Plugin 'wincent/command-t'
Plugin 'dense-analysis/ale'
call vundle#end()

set diffopt+=vertical
set completeopt=longest,menuone,preview,noselect
set foldmethod=syntax

" Gdiff highlighting colors
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

filetype plugin indent on
syntax on
