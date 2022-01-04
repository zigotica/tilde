vim.g.nvim_tree_highlight_opened_files = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_show_icons = {
  git= 1,
  folders= 1,
  files= 1,
  folder_arrows= 1
}

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
    auto_resize = true,
  }
}
