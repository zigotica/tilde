vim.cmd([[
  " Specify a directory for plugins
  call plug#begin('~/.config/nvim/plugged')

  " Basic extensions
  Plug 'tpope/vim-surround'
  Plug 'numToStr/Comment.nvim'

  " Lua basics
  Plug 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)

  " Menu 
  Plug 'kyazdani42/nvim-tree.lua'

  " Telescope core
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'

  " Languages
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/cmp-path'
  Plug 'jxnblk/vim-mdx-js'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'windwp/nvim-autopairs'
  Plug 'windwp/nvim-ts-autotag'
  Plug 'mattn/emmet-vim'
  Plug 'editorconfig/editorconfig-vim'

  " Git
  Plug 'lewis6991/gitsigns.nvim'

  " Status
  Plug 'nvim-lualine/lualine.nvim'

  " Colorschemes
  Plug 'zigotica/nightfox.nvim', {'branch': 'main'}
  Plug 'norcalli/nvim-colorizer.lua'

  " Initialize plugin system
  call plug#end()
]])
