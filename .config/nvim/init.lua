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
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.g.mapleader = " "

-- Runtime paths (corrected version)
local vim_path = vim.fn.expand('~/.vim')
local vim_after_path = vim.fn.expand('~/.vim/after')
vim.opt.runtimepath:append(vim_path)
vim.opt.runtimepath:append(vim_after_path)
vim.opt.packpath = vim.opt.runtimepath._value

-- Initialize lazy.nvim
require("lazy").setup({
 {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {"python", "markdown", "yaml"},
        highlight = { enable = true },
        indent = { enable = true },
        fold = { enable = true },
      }
    end
  },
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
 { "junegunn/fzf", build = "./install --bin" },
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
{
   "nvim-tree/nvim-tree.lua"
},
{
        'kevinhwang91/nvim-ufo',
        dependencies = {'kevinhwang91/promise-async'},
        config = function()
            vim.o.foldcolumn = '1'
            vim.o.foldlevel = 99 
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
            
            vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
            vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
            
            require('ufo').setup({
                provider_selector = function()
                    return {'treesitter', 'indent'}
                end
            })
        end
},
})

-- nvim-tree setup
require('nvim-tree').setup()

-- Key Mappings
local map = vim.keymap.set
-- Search and replace
map('n', '<Leader>/', ':%s/', { noremap = true })
map('v', '<Leader>/', ':s/\\%V', { noremap = true })

-- Clipboard operations
map('n', '<Leader>y', '"+y', { noremap = true })
map('n', '<Leader>p', '"+p', { noremap = true })
map('v', '<Leader>y', '"+y', { noremap = true })
map('n', '<leader>.', 'oimport ipdb; ipdb.set_trace()<Esc>', { noremap = true, silent = true })

-- Fuzzy finder
map('n', '<leader>t', '<cmd>lua require("fzf-lua").files()<CR>', { noremap = true })
map('n', '<Leader>b', '<cmd>lua require("fzf-lua").buffers()<CR>', { noremap = true })
map('n', '<Leader>fg', '<cmd>lua require("fzf-lua").live_grep()<CR>', { noremap = true })
-- Set colorscheme
vim.cmd('colorscheme custom')
