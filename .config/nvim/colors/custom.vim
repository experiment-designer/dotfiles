" Clear existing highlighting and set defaults
highlight clear
if exists("syntax_on")
  syntax reset
endif

" Define our colors from your theme
let colors = {
      \ 'brightyellow': '#ffaf00',
      \ 'brightorange': '#ff8700',
      \ 'mediumorange': '#d75f00',
      \ 'gray2': '#303030',
      \ 'darkestgreen': '#005f00',
      \ 'white': '#ffffff'
      \ }

" Set background
set background=dark

" Basic editor colors
"highlight Normal       guifg=#ffffff guibg=#303030
highlight Normal       guifg=#ffffff guibg=#1c1c1c
highlight LineNr       guifg=#666666 guibg=#303030
highlight CursorLine   guibg=#3a3a3a
highlight CursorLineNr guifg=#ff8700 guibg=#3a3a3a gui=bold
highlight Visual       guibg=#3a3a3a
highlight Search       guifg=#303030 guibg=#ffaf00
highlight IncSearch    guifg=#303030 guibg=#ff8700
highlight StatusLine   guifg=#ffffff guibg=#303030
highlight VertSplit    guifg=#666666 guibg=NONE gui=NONE

" Syntax highlighting
highlight Comment      guifg=#666666 gui=italic
highlight Constant     guifg=#ffaf00
highlight String      guifg=#87d75f
highlight Character   guifg=#87d75f
highlight Number      guifg=#ff8700
highlight Boolean     guifg=#ff8700
highlight Float       guifg=#ff8700
highlight Identifier   guifg=#ffffff
highlight Function     guifg=#ff8700
highlight Statement    guifg=#ff8700 gui=bold
highlight Keyword      guifg=#ff8700
highlight PreProc      guifg=#ffaf00
highlight Type         guifg=#ffaf00 gui=NONE
highlight Special      guifg=#ff8700
highlight Error        guifg=#ffffff guibg=#d75f00
highlight Todo         guifg=#303030 guibg=#ffaf00 gui=bold
highlight Directory    guifg=#ffaf00

" Git diff colors
highlight DiffAdd     guifg=#87d75f guibg=#005f00
highlight DiffChange  guifg=#ffaf00 guibg=#5f5f00
highlight DiffDelete  guifg=#d75f00 guibg=#5f0000
highlight DiffText    guifg=#ffffff guibg=#d75f00 gui=bold

" Popup menu
highlight Pmenu        guifg=#ffffff guibg=#444444
highlight PmenuSel     guifg=#303030 guibg=#ff8700
highlight PmenuSbar    guibg=#666666
highlight PmenuThumb   guibg=#ffffff
