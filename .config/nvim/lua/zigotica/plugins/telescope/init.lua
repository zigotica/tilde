require('telescope').setup{
defaults = {
  prompt_prefix = "z: ",
  mappings = {-- change default Enter to open in right split
  n = {
    ["<CR>"] = "select_vertical"
    },
  i = {
    ["<CR>"] = "select_vertical",
    ["<C-h>"] = "which_key"
    }
  }
},
  pickers = {
    find_files = {
      find_command=rg,
      },
    buffers = {
      mappings = {-- restore default Enter to open in same split
      n = {
        ["<CR>"] = "select_default"
        },
      i = {
        ["<CR>"] = "select_default"
        }
      }
    }
  }
}
