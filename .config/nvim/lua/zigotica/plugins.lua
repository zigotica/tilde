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

  -- Menu 
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = 'kyazdani42/nvim-web-devicons',
  },

  -- Telescope core
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',  
  },

  -- Languages
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/nvim-cmp',
  {
    'tzachar/cmp-tabnine',
    build = './install.sh',
    dependencies = 'hrsh7th/nvim-cmp',
  },
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

  -- Git
  'lewis6991/gitsigns.nvim',

  -- Status
  {
    'nvim-lualine/lualine.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
  },

  -- Colorschemes
  {
    'zigotica/nightfox.nvim',
    branch = 'main',
  },
  'norcalli/nvim-colorizer.lua',
})
