-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.opt.number = true
vim.g.mapleader = " "

-- Runtime paths (corrected version)
local vim_path = vim.fn.expand('~/.vim')
local vim_after_path = vim.fn.expand('~/.vim/after')
vim.opt.runtimepath:append(vim_path)
vim.opt.runtimepath:append(vim_after_path)
vim.opt.packpath = vim.opt.runtimepath._value

-- Initialize lazy.nvim
require("lazy").setup({
 -- Status line and theming
 {
   "nvim-lualine/lualine.nvim",
   dependencies = {
     "nvim-tree/nvim-web-devicons",
   },
   config = function()
     -- Define theme colors
     local colors = {
       brightyellow = '#ffaf00',
       brightorange = '#ff8700',
       mediumorange = '#d75f00',
       gray2 = '#303030',
       darkestgreen = '#005f00',
       white = '#ffffff'
     }
     
     require('lualine').setup {
       options = {
         theme = {
           normal = {
             a = { bg = colors.brightorange, fg = colors.gray2, gui = 'bold' },
             b = { bg = colors.mediumorange, fg = colors.white },
             c = { bg = colors.gray2, fg = colors.white }
           },
           insert = {
             a = { bg = colors.brightyellow, fg = colors.gray2, gui = 'bold' },
             b = { bg = colors.mediumorange, fg = colors.white },
             c = { bg = colors.gray2, fg = colors.white }
           },
           visual = {
             a = { bg = colors.white, fg = colors.gray2, gui = 'bold' },
             b = { bg = colors.mediumorange, fg = colors.white },
             c = { bg = colors.gray2, fg = colors.white }
           }
         },
         component_separators = { left = '', right = ''},
         section_separators = { left = '', right = ''}
       }
     }
   end,
 },

 -- Fuzzy finding
 {
   "ibhagwan/fzf-lua",
   dependencies = {
     "nvim-tree/nvim-web-devicons",
   },
   config = function()
     require('fzf-lua').setup({
       fzf = {
         ["<C-v>"] = "vsplit",
         ["<C-s>"] = "split",
         ["<C-t>"] = "tabedit",
       },
     })
   end,
 },

 -- Avante and its dependencies
 {
   "yetone/avante.nvim",
   event = "VeryLazy",
   lazy = false,
   version = false,
   opts = {
     -- add any opts here
   },
   build = "make",
   dependencies = {
     "nvim-treesitter/nvim-treesitter",
     "stevearc/dressing.nvim",
     "nvim-lua/plenary.nvim",
     "MunifTanjim/nui.nvim",
     -- Optional dependencies
     "nvim-tree/nvim-web-devicons",
     {
       "HakonHarnes/img-clip.nvim",
       event = "VeryLazy",
       opts = {
         default = {
           embed_image_as_base64 = false,
           prompt_for_file_name = false,
           drag_and_drop = {
             insert_mode = true,
           },
           use_absolute_path = true,
         },
       },
     },
     {
       'MeanderingProgrammer/render-markdown.nvim',
       opts = {
         file_types = { "markdown", "Avante" },
       },
       ft = { "markdown", "Avante" },
     },
   },
 },
})

-- Key Mappings
local map = vim.keymap.set
-- Search and replace
map('n', '<Leader>/', ':%s/', { noremap = true })
map('v', '<Leader>/', ':s/\\%V', { noremap = true })
-- Clipboard operations
map('n', '<Leader>y', '"+y', { noremap = true })
map('n', '<Leader>p', '"+p', { noremap = true })
-- Fuzzy finder
map('n', '<leader>t', '<cmd>lua require("fzf-lua").files()<CR>', { noremap = true })
map('n', '<Leader>b', '<cmd>lua require("fzf-lua").buffers()<CR>', { noremap = true })

-- Set colorscheme
vim.cmd('colorscheme custom')
