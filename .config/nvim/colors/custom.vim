" Phosphor -- structure is near-white hairlines on near-black; state is lime.
highlight clear
if exists("syntax_on")
  syntax reset
endif

set background=dark
let g:colors_name = "custom"

" Editor structure
highlight Normal                   guifg=#e6e9ed guibg=#07080a
highlight NormalNC                 guifg=#9aa1ab guibg=#07080a
highlight CursorLine               guibg=#0d0f12
highlight LineNr                   guifg=#5b626c guibg=#07080a
highlight CursorLineNr             guifg=#c3f542 guibg=#0d0f12 gui=bold
highlight SignColumn               guifg=#5b626c guibg=#07080a
highlight FoldColumn               guifg=#5b626c guibg=#07080a
highlight Folded                   guifg=#9aa1ab guibg=#0d0f12
highlight ColorColumn              guibg=#0d0f12
highlight Visual                   guibg=#1c2027
highlight Search                   guifg=#07080a guibg=#ffb340
highlight CurSearch                guifg=#07080a guibg=#c3f542 gui=bold
highlight IncSearch                guifg=#07080a guibg=#c3f542 gui=bold
highlight MatchParen               guifg=#c3f542 guibg=NONE    gui=bold,underline
highlight NonText                  guifg=#262b33
highlight Whitespace               guifg=#262b33
highlight EndOfBuffer              guifg=#262b33
highlight WinSeparator             guifg=#e6e9ed guibg=NONE    gui=NONE
highlight VertSplit                guifg=#e6e9ed guibg=NONE    gui=NONE
highlight Cursor                   guifg=#07080a guibg=#c3f542

" Floating windows and popups
highlight NormalFloat              guifg=#e6e9ed guibg=#0d0f12
highlight FloatBorder              guifg=#e6e9ed guibg=#0d0f12
highlight FloatTitle               guifg=#c3f542 guibg=#0d0f12 gui=bold
highlight Pmenu                    guifg=#e6e9ed guibg=#0d0f12
highlight PmenuSel                 guifg=#c3f542 guibg=#1c2027 gui=bold
highlight PmenuMatch               guifg=#c3f542 guibg=#0d0f12
highlight PmenuMatchSel            guifg=#c3f542 guibg=#1c2027 gui=bold
highlight PmenuSbar                guibg=#14171c
highlight PmenuThumb               guibg=#5b626c
highlight StatusLine               guifg=#e6e9ed guibg=#0d0f12
highlight StatusLineNC             guifg=#5b626c guibg=#0d0f12
highlight TabLine                  guifg=#5b626c guibg=#0d0f12
highlight TabLineFill              guibg=#07080a
highlight TabLineSel               guifg=#c3f542 guibg=#07080a gui=bold
highlight WildMenu                 guifg=#07080a guibg=#c3f542 gui=bold
highlight Title                    guifg=#c3f542 gui=bold
highlight Directory                guifg=#5b9dff
highlight Question                 guifg=#c3f542
highlight MoreMsg                  guifg=#c3f542
highlight ModeMsg                  guifg=#9aa1ab
highlight ErrorMsg                 guifg=#ff4d6d
highlight WarningMsg               guifg=#ffb340
highlight QuickFixLine             guibg=#1c2027

" Standard syntax
highlight Comment                  guifg=#5b626c gui=italic
highlight String                   guifg=#5ed3f3
highlight Character                guifg=#5ed3f3
highlight Number                   guifg=#ffb340
highlight Float                    guifg=#ffb340
highlight Boolean                  guifg=#ffb340
highlight Constant                 guifg=#ffb340
highlight Identifier               guifg=#e6e9ed
highlight Function                 guifg=#e6e9ed gui=bold
highlight Statement                guifg=#d67cff
highlight Keyword                  guifg=#d67cff
highlight Conditional              guifg=#d67cff
highlight Repeat                   guifg=#d67cff
highlight Label                    guifg=#d67cff
highlight Exception                guifg=#d67cff
highlight Operator                 guifg=#9aa1ab
highlight PreProc                  guifg=#5b9dff
highlight Include                  guifg=#5b9dff
highlight Define                   guifg=#5b9dff
highlight Macro                    guifg=#5b9dff
highlight PreCondit                guifg=#5b9dff
highlight Type                     guifg=#5b9dff
highlight StorageClass             guifg=#5b9dff
highlight Structure                guifg=#5b9dff
highlight Typedef                  guifg=#5b9dff
highlight Special                  guifg=#c3f542
highlight SpecialChar              guifg=#c3f542
highlight Tag                      guifg=#c3f542
highlight Delimiter                guifg=#9aa1ab
highlight Todo                     guifg=#07080a guibg=#c3f542 gui=bold
highlight Error                    guifg=#f4f6f8 guibg=#3a1620
highlight Underlined               guifg=#5ed3f3 gui=underline

" Treesitter syntax
highlight @comment                 guifg=#5b626c gui=italic
highlight @string                  guifg=#5ed3f3
highlight @string.escape           guifg=#c3f542
highlight @string.regex            guifg=#5ed3f3
highlight @string.special          guifg=#c3f542
highlight @character               guifg=#5ed3f3
highlight @character.special       guifg=#c3f542
highlight @number                  guifg=#ffb340
highlight @number.float            guifg=#ffb340
highlight @boolean                 guifg=#ffb340
highlight @constant                guifg=#ffb340
highlight @constant.builtin        guifg=#ffb340
highlight @constant.macro          guifg=#ffb340
highlight @variable                guifg=#e6e9ed
highlight @variable.builtin        guifg=#d67cff
highlight @variable.parameter      guifg=#e6e9ed
highlight @variable.member         guifg=#e6e9ed
highlight @property                guifg=#e6e9ed
highlight @field                   guifg=#e6e9ed
highlight @function                guifg=#e6e9ed gui=bold
highlight @function.builtin        guifg=#e6e9ed gui=bold
highlight @function.call           guifg=#e6e9ed
highlight @function.macro          guifg=#5b9dff
highlight @method                  guifg=#5b9dff
highlight @function.method         guifg=#5b9dff
highlight @function.method.call    guifg=#5b9dff
highlight @constructor             guifg=#5b9dff
highlight @keyword                 guifg=#d67cff
highlight @keyword.function        guifg=#d67cff
highlight @keyword.return          guifg=#d67cff
highlight @keyword.operator        guifg=#d67cff
highlight @keyword.coroutine       guifg=#d67cff
highlight @keyword.conditional     guifg=#d67cff
highlight @keyword.repeat          guifg=#d67cff
highlight @keyword.import          guifg=#5b9dff
highlight @keyword.directive       guifg=#5b9dff
highlight @operator                guifg=#9aa1ab
highlight @punctuation.bracket     guifg=#9aa1ab
highlight @punctuation.delimiter   guifg=#9aa1ab
highlight @punctuation.special     guifg=#c3f542
highlight @type                    guifg=#5b9dff
highlight @type.builtin            guifg=#5b9dff
highlight @type.definition         guifg=#5b9dff
highlight @type.qualifier          guifg=#d67cff
highlight @attribute               guifg=#c3f542
highlight @tag                     guifg=#d67cff
highlight @tag.attribute           guifg=#5b9dff
highlight @tag.delimiter           guifg=#9aa1ab
highlight @markup.heading          guifg=#c3f542 gui=bold
highlight @markup.link.url         guifg=#5ed3f3 gui=underline
highlight @markup.link             guifg=#5ed3f3
highlight @markup.link.label       guifg=#c3f542
highlight @markup.raw              guifg=#5ed3f3
highlight @markup.raw.block        guifg=#5ed3f3
highlight @markup.list             guifg=#c3f542
highlight @markup.list.checked     guifg=#c3f542
highlight @markup.list.unchecked   guifg=#5b626c
highlight @markup.strong           gui=bold
highlight @markup.italic           gui=italic

" LSP Semantic Tokens
highlight default link @lsp.type.comment     @comment
highlight default link @lsp.type.string      @string
highlight default link @lsp.type.keyword     @keyword
highlight default link @lsp.type.number      @number
highlight default link @lsp.type.boolean     @boolean
highlight default link @lsp.type.variable    @variable
highlight default link @lsp.type.parameter   @variable.parameter
highlight default link @lsp.type.property    @property
highlight default link @lsp.type.function    @function
highlight default link @lsp.type.method      @method
highlight default link @lsp.type.type        @type
highlight default link @lsp.type.class       @type
highlight default link @lsp.type.interface   @type
highlight default link @lsp.type.enum        @type
highlight default link @lsp.type.enumMember  @constant
highlight default link @lsp.type.macro       Macro
highlight default link @lsp.type.operator    @operator
highlight default link @lsp.type.namespace   @type
highlight default link @lsp.type.decorator   @attribute

" Diagnostics
highlight DiagnosticError          guifg=#ff4d6d
highlight DiagnosticWarn           guifg=#ffb340
highlight DiagnosticInfo           guifg=#5b9dff
highlight DiagnosticHint           guifg=#5ed3f3

highlight DiagnosticUnderlineError gui=undercurl guisp=#ff4d6d
highlight DiagnosticUnderlineWarn  gui=undercurl guisp=#ffb340
highlight DiagnosticUnderlineInfo  gui=undercurl guisp=#5b9dff
highlight DiagnosticUnderlineHint  gui=undercurl guisp=#5ed3f3

" Diff & Git
highlight DiffAdd                  guifg=#c3f542 guibg=#10190a
highlight DiffChange               guifg=#ffb340 guibg=#1c1608
highlight DiffDelete               guifg=#ff4d6d guibg=#1e0a10
highlight DiffText                 guifg=#f4f6f8 guibg=#2a2f38 gui=bold

highlight GitSignsAdd              guifg=#c3f542 guibg=NONE
highlight GitSignsChange           guifg=#ffb340 guibg=NONE
highlight GitSignsDelete           guifg=#ff4d6d guibg=NONE

" Plugins
highlight NvimTreeNormal           guifg=#9aa1ab guibg=#07080a
highlight NvimTreeNormalNC         guifg=#9aa1ab guibg=#07080a
highlight NvimTreeRootFolder       guifg=#c3f542 gui=bold
highlight NvimTreeFolderName       guifg=#5b9dff
highlight NvimTreeOpenedFolderName guifg=#5ed3f3
highlight NvimTreeWinSeparator     guifg=#e6e9ed guibg=NONE

highlight FzfLuaNormal             guifg=#e6e9ed guibg=#0d0f12
highlight FzfLuaBorder             guifg=#e6e9ed guibg=#0d0f12
highlight FzfLuaTitle              guifg=#c3f542 guibg=#0d0f12 gui=bold
highlight FzfLuaPreviewNormal      guifg=#e6e9ed guibg=#07080a
highlight FzfLuaPreviewBorder      guifg=#e6e9ed guibg=#07080a
highlight FzfLuaPreviewTitle       guifg=#c3f542 guibg=#07080a gui=bold
highlight FzfLuaCursorLine         guibg=#1c2027
highlight FzfLuaHeaderText         guifg=#9aa1ab

highlight TelescopeNormal          guifg=#e6e9ed guibg=#0d0f12
highlight TelescopeBorder          guifg=#e6e9ed guibg=#0d0f12
highlight TelescopeTitle           guifg=#c3f542 guibg=#0d0f12 gui=bold
highlight TelescopeSelection       guifg=#c3f542 guibg=#1c2027 gui=bold
highlight TelescopePreviewNormal   guifg=#e6e9ed guibg=#07080a
highlight TelescopePreviewBorder   guifg=#e6e9ed guibg=#07080a
