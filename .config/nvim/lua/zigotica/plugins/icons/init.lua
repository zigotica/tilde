require'nvim-web-devicons'.setup {
  override = {
    ["test.spec.js"] = {
      icon = "ﭧ",
      color = "#e0bb70",
      name = "JavascriptTest"
    },
    ["tsx"] = {
      icon = "",
      color = "#99d7e8",
      name = "TSReact"
    },
    ["html"] = {
      icon = "",
      color = "#99d7e8",
      name = "HTML"
    },
    ["md"] = {
      icon = "",
      color = "#99d7e8",
      name = "Markdown"
    }
  },
  default = true;
}
