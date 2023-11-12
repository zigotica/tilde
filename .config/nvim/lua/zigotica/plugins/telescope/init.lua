local shared_icons = require"zigotica.common.icons"

require('telescope').setup{
  defaults = {
    prompt_prefix = ' '..shared_icons.search..' ',
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = "top",
    },
    mappings = {
      i = {
        ["<C-h>"] = "which_key"
      }
    },
    file_ignore_patterns = {
      "node_modules",
      "dist",
      "vendor",
      "build",
      "history",
      "plugged",
      ".DS_Store"
    },
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
  },
  extensions = {
    glyph = {
      action = function(glyph)
        -- insert glyph when picked
        vim.api.nvim_put({ glyph.value }, 'c', false, true)
      end,
    },
  },
}

require('telescope').load_extension('undo')
require('telescope').load_extension('glyph')
