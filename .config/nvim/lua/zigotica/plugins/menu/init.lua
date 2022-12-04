require'nvim-tree'.setup {
  open_on_setup       = true,
  update_cwd          = true,
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = true,
    update_cwd  = true,
    ignore_list = {}
  },
  filters = {
    dotfiles = false,
    custom = {
      "build",
      "dist",
      "history",
      "node_modules",
      "vendor",
      ".DS_Store"
    }
  },
  view = {
    adaptive_size = true,
  },
  renderer = {
    highlight_opened_files = "none",
    group_empty = true,
    highlight_git = true,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      }
    }
  }
}
