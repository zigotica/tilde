require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "arduino",
    "awk",
    "bash",
    "c",
    "c_sharp",
    "cpp",
    "css",
    "csv",
    "diff",
    "dockerfile",
    "gitignore",
    "go",
    "graphql",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "python",
    "scss",
    "ssh_config",
    "terraform",
    "tsx",
    "typescript",
    "vue",
    "yaml",
  },
  sync_install = true,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  autotag = {
    enable = true,
  },
  indent = {
    enable = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-Space>",
      node_incremental = "<C-Space>",
      scope_incremental = false,
      node_decremental = "<bs>",
    },
  },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
        ["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>sf"] = { query = "@function.outer", desc = "Swap function with next one" },
        ["<leader>sp"] = { query = "@parameter.inner", desc = "Swap parameter with next one" },
      },
      swap_previous = {
        ["<leader>Sf"] = { query = "@function.outer", desc = "Swap function with previous one" },
        ["<leader>Sp"] = { query = "@parameter.inner", desc = "Swap parameter with previous one" },
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["{n"] = { query = "@function.outer", desc = "Move to next function start" },
      },
      goto_previous_start = {
        ["{N"] = { query = "@function.outer", desc = "Move to previous function start" },
      },
    },
  },
}
