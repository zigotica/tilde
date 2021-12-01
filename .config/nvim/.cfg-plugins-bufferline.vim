lua << EOF
require'nvim-web-devicons'.setup {
  override = {
    ["test.spec.js"] = {
      icon = "ﭧ",
      color = "#cbcb41",
      name = "JavascriptTest"
    }
  },
  -- globally enable default icons (default to false)
  -- will get overriden by `get_icons` option
  default = true;
  }
EOF

lua << EOF
require("bufferline").setup{
options = {
    diagnostics = "coc"
  }
}
EOF
