" Phosphor -- structure is near-white hairlines on deep graphite; state is amber.
highlight clear
if exists("syntax_on")
  syntax reset
endif

set background=dark
let g:colors_name = "custom"

" Editor structure
highlight Normal                   guifg=#e6e9ed guibg=#16181d
highlight NormalNC                 guifg=#b7bec8 guibg=#16181d
highlight CursorLine               guibg=#1c1f25
highlight LineNr                   guifg=#7b838f guibg=#16181d
highlight CursorLineNr             guifg=#ffb340 guibg=#1c1f25 gui=bold
highlight SignColumn               guifg=#7b838f guibg=#16181d
highlight FoldColumn               guifg=#7b838f guibg=#16181d
highlight Folded                   guifg=#b7bec8 guibg=#1c1f25
highlight ColorColumn              guibg=#1c1f25
highlight Visual                   guibg=#2c313a
highlight Search                   guifg=#16181d guibg=#ffd866
highlight CurSearch                guifg=#16181d guibg=#ffb340 gui=bold
highlight IncSearch                guifg=#16181d guibg=#ffb340 gui=bold
highlight MatchParen               guifg=#ffb340 guibg=NONE    gui=bold,underline
highlight NonText                  guifg=#3a404a
highlight Whitespace               guifg=#3a404a
highlight EndOfBuffer              guifg=#3a404a
highlight WinSeparator             guifg=#e6e9ed guibg=NONE    gui=NONE
highlight VertSplit                guifg=#e6e9ed guibg=NONE    gui=NONE
highlight Cursor                   guifg=#16181d guibg=#ffb340

" Floating windows and popups
highlight NormalFloat              guifg=#e6e9ed guibg=#1c1f25
highlight FloatBorder              guifg=#e6e9ed guibg=#1c1f25
highlight FloatTitle               guifg=#ffb340 guibg=#1c1f25 gui=bold
highlight Pmenu                    guifg=#e6e9ed guibg=#1c1f25
highlight PmenuSel                 guifg=#ffb340 guibg=#2c313a gui=bold
highlight PmenuMatch               guifg=#ffb340 guibg=#1c1f25
highlight PmenuMatchSel            guifg=#ffb340 guibg=#2c313a gui=bold
highlight PmenuSbar                guibg=#23272e
highlight PmenuThumb               guibg=#7b838f
highlight StatusLine               guifg=#e6e9ed guibg=#1c1f25
highlight StatusLineNC             guifg=#7b838f guibg=#1c1f25
highlight TabLine                  guifg=#7b838f guibg=#1c1f25
highlight TabLineFill              guibg=#16181d
highlight TabLineSel               guifg=#ffb340 guibg=#16181d gui=bold
highlight WildMenu                 guifg=#16181d guibg=#ffb340 gui=bold
highlight Title                    guifg=#5b9dff gui=bold
highlight Directory                guifg=#5b9dff
highlight Question                 guifg=#ffb340
highlight MoreMsg                  guifg=#ffb340
highlight ModeMsg                  guifg=#b7bec8
highlight ErrorMsg                 guifg=#ff4d6d
highlight WarningMsg               guifg=#ffd866
highlight QuickFixLine             guibg=#2c313a

" Standard syntax
highlight Comment                  guifg=#7b838f gui=italic
highlight String                   guifg=#98c379
highlight Character                guifg=#98c379
highlight Number                   guifg=#e5c07b
highlight Float                    guifg=#e5c07b
highlight Boolean                  guifg=#e5c07b
highlight Constant                 guifg=#e5c07b
highlight Identifier               guifg=#e6e9ed
highlight Function                 guifg=#e6e9ed gui=bold
highlight Statement                guifg=#d67cff
highlight Keyword                  guifg=#d67cff
highlight Conditional              guifg=#d67cff
highlight Repeat                   guifg=#d67cff
highlight Label                    guifg=#d67cff
highlight Exception                guifg=#d67cff
highlight Operator                 guifg=#b7bec8
highlight PreProc                  guifg=#5b9dff
highlight Include                  guifg=#5b9dff
highlight Define                   guifg=#5b9dff
highlight Macro                    guifg=#5b9dff
highlight PreCondit                guifg=#5b9dff
highlight Type                     guifg=#5b9dff
highlight StorageClass             guifg=#5b9dff
highlight Structure                guifg=#5b9dff
highlight Typedef                  guifg=#5b9dff
highlight Special                  guifg=#5ed3f3
highlight SpecialChar              guifg=#ffd866
highlight Tag                      guifg=#ffb340
highlight Delimiter                guifg=#b7bec8
highlight Todo                     guifg=#16181d guibg=#ffb340 gui=bold
highlight Error                    guifg=#f4f6f8 guibg=#432130
highlight Underlined               guifg=#5b9dff gui=underline

" Treesitter syntax
highlight @comment                 guifg=#7b838f gui=italic
highlight @string                  guifg=#98c379
highlight @string.escape           guifg=#ffd866
highlight @string.regex            guifg=#98c379
highlight @string.special          guifg=#98c379
highlight @character               guifg=#98c379
highlight @character.special       guifg=#ffd866
highlight @number                  guifg=#e5c07b
highlight @number.float            guifg=#e5c07b
highlight @boolean                 guifg=#e5c07b
highlight @constant                guifg=#e5c07b
highlight @constant.builtin        guifg=#e5c07b
highlight @constant.macro          guifg=#e5c07b
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
highlight @operator                guifg=#b7bec8
highlight @punctuation.bracket     guifg=#b7bec8
highlight @punctuation.delimiter   guifg=#b7bec8
highlight @punctuation.special     guifg=#5ed3f3
highlight @type                    guifg=#5b9dff
highlight @type.builtin            guifg=#5b9dff
highlight @type.definition         guifg=#5b9dff
highlight @type.qualifier          guifg=#d67cff
highlight @attribute               guifg=#ffb340
highlight @tag                     guifg=#d67cff
highlight @tag.attribute           guifg=#5b9dff
highlight @tag.delimiter           guifg=#b7bec8
highlight @markup.heading          guifg=#5b9dff gui=bold
highlight @markup.link.url         guifg=#5ed3f3 gui=underline
highlight @markup.link             guifg=#5b9dff
highlight @markup.link.label       guifg=#ffb340
highlight @markup.raw              guifg=#e6e9ed
highlight @markup.raw.block        guifg=#e6e9ed
highlight @markup.list             guifg=#ffb340
highlight @markup.list.checked     guifg=#ffb340
highlight @markup.list.unchecked   guifg=#7b838f
highlight @markup.strong           gui=bold
highlight @markup.italic           gui=italic

" Filetype headers
highlight default link tomlTable        Title
highlight default link tomlTableArray   Title
highlight default link dosiniHeader     Title
highlight default link @type.toml       Title

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
highlight DiagnosticWarn           guifg=#ffd866
highlight DiagnosticInfo           guifg=#5b9dff
highlight DiagnosticHint           guifg=#5b9dff

highlight DiagnosticUnderlineError gui=undercurl guisp=#ff4d6d
highlight DiagnosticUnderlineWarn  gui=undercurl guisp=#ffd866
highlight DiagnosticUnderlineInfo  gui=undercurl guisp=#5b9dff
highlight DiagnosticUnderlineHint  gui=undercurl guisp=#5b9dff

" Diff & Git
highlight DiffAdd                  guifg=#98c379 guibg=#1f2b1c
highlight DiffChange               guifg=#ffd866 guibg=#2b281c
highlight DiffDelete               guifg=#ff4d6d guibg=#2d1c22
highlight DiffText                 guifg=#f4f6f8 guibg=#3a404a gui=bold

highlight GitSignsAdd              guifg=#98c379 guibg=NONE
highlight GitSignsChange           guifg=#ffd866 guibg=NONE
highlight GitSignsDelete           guifg=#ff4d6d guibg=NONE

" Plugins
highlight NvimTreeNormal           guifg=#b7bec8 guibg=#16181d
highlight NvimTreeNormalNC         guifg=#b7bec8 guibg=#16181d
highlight NvimTreeRootFolder       guifg=#ffb340 gui=bold
highlight NvimTreeFolderName       guifg=#5b9dff
highlight NvimTreeOpenedFolderName guifg=#5ed3f3
highlight NvimTreeWinSeparator     guifg=#e6e9ed guibg=NONE

highlight FzfLuaNormal             guifg=#e6e9ed guibg=#1c1f25
highlight FzfLuaBorder             guifg=#e6e9ed guibg=#1c1f25
highlight FzfLuaTitle              guifg=#ffb340 guibg=#1c1f25 gui=bold
highlight FzfLuaPreviewNormal      guifg=#e6e9ed guibg=#16181d
highlight FzfLuaPreviewBorder      guifg=#e6e9ed guibg=#16181d
highlight FzfLuaPreviewTitle       guifg=#ffb340 guibg=#16181d gui=bold
highlight FzfLuaCursorLine         guibg=#2c313a
highlight FzfLuaHeaderText         guifg=#b7bec8

highlight TelescopeNormal          guifg=#e6e9ed guibg=#1c1f25
highlight TelescopeBorder          guifg=#e6e9ed guibg=#1c1f25
highlight TelescopeTitle           guifg=#ffb340 guibg=#1c1f25 gui=bold
highlight TelescopeSelection       guifg=#ffb340 guibg=#2c313a gui=bold
highlight TelescopePreviewNormal   guifg=#e6e9ed guibg=#16181d
highlight TelescopePreviewBorder   guifg=#e6e9ed guibg=#16181d
