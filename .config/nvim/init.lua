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

local treesitter_parsers = {
  "bash",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "yaml",
}

local treesitter_filetypes = {
  "json",
  "jsonc",
  "lua",
  "markdown",
  "python",
  "sh",
  "yaml",
}

-- Initialize lazy.nvim
require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = function()
      require("nvim-treesitter").install(treesitter_parsers):wait(300000)
    end,
    config = function()
      require("nvim-treesitter").setup({})
      vim.treesitter.language.register("json", "jsonc")
      vim.api.nvim_create_autocmd("FileType", {
        pattern = treesitter_filetypes,
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
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
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    init = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function()
      local ufo = require("ufo")

      ufo.setup({
        provider_selector = function(_, _, buftype)
          if buftype ~= "" then
            return ""
          end
          return { "treesitter", "indent" }
        end,
        fold_virt_text_handler = function(virtual_text, start_line, end_line, width, truncate)
          local suffix = ("  … %d lines"):format(end_line - start_line)
          local suffix_width = vim.fn.strdisplaywidth(suffix)
          local target_width = width - suffix_width
          local result = {}
          local current_width = 0

          for _, chunk in ipairs(virtual_text) do
            local text, highlight = chunk[1], chunk[2]
            local chunk_width = vim.fn.strdisplaywidth(text)
            if target_width > current_width + chunk_width then
              table.insert(result, chunk)
              current_width = current_width + chunk_width
            else
              text = truncate(text, target_width - current_width)
              table.insert(result, { text, highlight })
              current_width = current_width + vim.fn.strdisplaywidth(text)
              if current_width < target_width then
                suffix = suffix .. (" "):rep(target_width - current_width)
              end
              break
            end
          end

          table.insert(result, { suffix, "MoreMsg" })
          return result
        end,
      })

      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "Open one fold level" })
      vim.keymap.set("n", "zm", ufo.closeFoldsWith, { desc = "Close one fold level" })
      vim.keymap.set("n", "zK", function()
        local preview_window = ufo.peekFoldedLinesUnderCursor()
        if not preview_window then
          vim.lsp.buf.hover()
        end
      end, { desc = "Preview folded lines" })
    end,
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
