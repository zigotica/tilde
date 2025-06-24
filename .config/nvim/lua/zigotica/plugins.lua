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
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- list of plugins and dependencies
require("lazy").setup({
  -- Basic extensions
  "tpope/vim-surround",
  "mg979/vim-visual-multi",
  "numToStr/Comment.nvim",

  -- Telescope core
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- Telescope extensions
  {
    -- useful for days when the z12 micropad w/ rotary encoder not at hand
    -- https://github.com/zigotica/mechanical-keyboards/tree/main/z12
    "debugloop/telescope-undo.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "nvim-telescope/telescope-symbols.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "ghassan0/telescope-glyph.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "zigotica/telescope-docker-commands.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },

  -- FZF direct replacement for telescope find_files (was too slow)
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      { "junegunn/fzf", build = "./install --bin" },
    },
  },

  -- Languages
  "neovim/nvim-lspconfig",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/nvim-cmp",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "hrsh7th/cmp-path",
  "jxnblk/vim-mdx-js",
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = "nvim-lua/plenary.nvim",
  },
  "windwp/nvim-autopairs",
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  "mattn/emmet-vim",
  "editorconfig/editorconfig-vim",
  {
    "kevinhwang91/nvim-bqf",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  "pearofducks/ansible-vim",

  -- AI completion
  {
    "tzachar/cmp-tabnine",
    build = "./install.sh",
    dependencies = "hrsh7th/nvim-cmp",
  },
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
  },

  -- AI menu with code and english actions
  { "David-Kunz/gen.nvim" },

  -- AI with filesystem / diff apply support
  {
    "yetone/avante.nvim",
    -- commit = "f9aa754", -- before agentic mode
    -- checker = { check_pinned = true },
    event = "VeryLazy",
    lazy = false,
    version = false, -- always pull the latest change
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },


  -- Testing
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "haydenmeade/neotest-jest",
      "antoinemadec/FixCursorHold.nvim",
    },
    ft = { "js", "ts", "jsx", "tsx" },
  },

  -- Git
  "lewis6991/gitsigns.nvim",

  -- Colors
  "edeneast/nightfox.nvim",
  "norcalli/nvim-colorizer.lua",

  -- Markdown viewer; other options:
  --   "OXY2DEV/markview.nvim",
  --   "toppair/peek.nvim",
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- Menu
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = "kyazdani42/nvim-web-devicons",
  },

  -- Status
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "kyazdani42/nvim-web-devicons",
  },
})
