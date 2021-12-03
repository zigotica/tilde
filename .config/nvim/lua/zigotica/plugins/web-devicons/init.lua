require'nvim-web-devicons'.setup {
  override = {
    ["test.spec.js"] = {
      icon = "ﭧ",
      color = "#cbcb41",
      name = "JavascriptTest"
    },
    ["tsx"] = {
      icon = "",
      color = "#81a1c1",
      name = "TSReact"
    },
    ["html"] = {
      icon = "",
      color = "#81a1c1",
      name = "HTML"
    },
    ["md"] = {
      icon = "",
      color = "#81a1c1",
      name = "Markdown"
    }
  },
  default = true;
}
