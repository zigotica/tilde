require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "css",
    "scss",
    "html",
    "json",
    "javascript",
    "typescript",
    "tsx",
    "yaml",
    "lua",
  },
  sync_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  autotag = {
    enable = true,
  }
}
