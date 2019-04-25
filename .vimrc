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

let g:tex_flavor='latex'

" Replace all
noremap <Leader>/ :%s/

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
let g:CommandTMaxFiles=200000
let g:CommandTTraverseSCM='pwd'

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
    return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
    For no inserting <CR> key.
    "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"


" Pymode
let g:pymode_python = 'python3'
let g:pymode_rope = 1
let g:pymode_rope_lookup_project = 1
let g:pymode_breakpoint_bind = '<Leader>d'
let g:pymode_folding = 1

" Solves some weird insert mode bug
set backspace=indent,eol,start


call pathogen#infect()
call pathogen#helptags()
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'rking/ag.vim'
" Plugin 'Shougo/neocomplete.vim'
Plugin 'Konfekt/FastFold'
" Plugin 'scrooloose/syntastic'
Plugin 'klen/python-mode'
Plugin 'tpope/vim-fugitive'
" Seem to collide with the libraries plugin
Plugin 'tpope/vim-commentary'
" Plugin 'vim-latex/vim-latex'
Plugin 'lervag/vimtex'
Plugin 'wincent/command-t'
Plugin 'francoiscabrol/ranger.vim'
call vundle#end()

set diffopt+=vertical

" Gdiff highlighting colors
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

filetype plugin indent on
syntax on
set foldmethod=syntax
