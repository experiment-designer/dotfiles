let mapleader=" " 
set number
set autoindent
set expandtab
set tabstop=8
set shiftwidth=4
set softtabstop=4
set ignorecase
set smartcase
let python_highlight_all = 1
let g:tex_flavor='latex'

" Syntastic recommended settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" used by the javascript libraries plugin
let g:used_javascript_libs = 'angularjs, angularui, angularuirouter'
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

" Command-T settings
let g:CommandTMaxFiles=200000

" Snipmate default key
" <Space> closes neocomplete popup, <BS> deletes the new space
" TODO: less hacky solution?
imap <C-s> <Space><BS><Plug>snipMateNextOrTrigger
smap <C-s> <Plug>snipMateNextOrTrigger

" neocomplete settings

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
            \ 'default' : '',
            \ 'vimshell' : $HOME.'/.vimshell_hist',
            \ 'scheme' : $HOME.'/.gosh_completions'
            \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g> neocomplete#undo_completion()
inoremap <expr><C-l> neocomplete#complete_common_string()

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
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif

"let g:neocomplete#sources#omni#input_patterns.php = '[^.\t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'


" TODO: dynamically append syntaxcomplete#Complete to every value
let g:neocomplete#sources#omni#functions = {
	\ 'css': ['csscomplete#CompleteCSS', 'syntaxcomplete#Complete'],
	\ 'html': ['htmlcomplete#CompleteTags', 'syntaxcomplete#Complete'],
	\ 'javascript': ['javascriptcomplete#CompleteJS', 'syntaxcomplete#Complete'],
	\ 'python': ['pythoncomplete#Complete'],
        \ 'xml' : ['xmlcomplete#CompleteTags'],
        \ '_' : ['syntaxcomplete#Complete']
\ }

" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
 
call pathogen#infect()
call pathogen#helptags()
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'Shougo/neocomplete.vim'
Plugin 'scrooloose/syntastic'
Plugin 'burnettk/vim-angular'
Plugin 'matthewsimo/angular-vim-snippets'
Plugin 'othree/javascript-libraries-syntax.vim'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'klen/python-mode'
Plugin 'tpope/vim-fugitive'
Plugin 'leafgarland/typescript-vim'
" Seem to collide with the libraries plugin
Plugin 'pangloss/vim-javascript'
Plugin 'tpope/vim-commentary'
Plugin 'vim-latex/vim-latex'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
Plugin 'Shougo/unite.vim'
Plugin 'Shougo/vimfiler.vim'
Plugin 'wincent/command-t'
call vundle#end()

" filetype plugin indent on
syntax on
" set foldmethod=syntax
