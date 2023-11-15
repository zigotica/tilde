-- Install lazy plugin manager if needed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- lazy requires leader key to be defined before plugins are required
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- list of plugins and dependencies
require("lazy").setup({
  -- Basic extensions
  'tpope/vim-surround',
  'numToStr/Comment.nvim',

  -- Telescope core
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',  
  },

  -- Telescope extensions
  {
    -- useful for days when the z12 micropad w/ rotary encoder not at hand
    -- https://github.com/zigotica/mechanical-keyboards/tree/main/z12
    'debugloop/telescope-undo.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    }
  },
  {
    'nvim-telescope/telescope-symbols.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    }
  },
  {
    'ghassan0/telescope-glyph.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    }
  },

  -- Languages
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
  'hrsh7th/cmp-path',
  'jxnblk/vim-mdx-js',
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },
  'windwp/nvim-autopairs',
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },
  'mattn/emmet-vim',
  'editorconfig/editorconfig-vim',
  {
    'kevinhwang91/nvim-bqf',
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },

  -- AI completion
  {
    'tzachar/cmp-tabnine',
    build = './install.sh',
    dependencies = 'hrsh7th/nvim-cmp',
  },
  {
    'Exafunction/codeium.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
  },

  -- Testing
  {
    'nvim-neotest/neotest',
    dependencies = {
      'haydenmeade/neotest-jest',
      'antoinemadec/FixCursorHold.nvim',
    },
    ft = { 'js', 'ts', 'jsx', 'tsx' },
  },

  -- Git
  'lewis6991/gitsigns.nvim',

  -- Colors
  'edeneast/nightfox.nvim',
  'norcalli/nvim-colorizer.lua',

  -- Menu 
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = 'kyazdani42/nvim-web-devicons',
  },

  -- Status
  {
    'nvim-lualine/lualine.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
  },
})
