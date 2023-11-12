local shared_icons = require"zigotica.common.icons"

local function custom_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- use all default mappings
  -- see list at https://github.com/nvim-tree/nvim-tree.lua/blob/master/lua/nvim-tree/keymap.lua
  api.config.mappings.default_on_attach(bufnr)

  --  override some defaults, add new mappings
  vim.keymap.set('n', 'm', api.fs.rename_full, opts('Move')) -- same as rename_full (u)
  vim.keymap.set('n', 'b', api.marks.toggle, opts('Toggle Bookmark'))
  vim.keymap.set('n', 'd', api.fs.trash, opts('Trash'))
  vim.keymap.set('n', 'Bd', api.marks.bulk.trash, opts('Trash Bookmarked'))
  vim.keymap.set('n', 'Bm', api.marks.bulk.move, opts('Move Bookmarked'))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
end

require'nvim-tree'.setup {
  update_cwd          = true,
  diagnostics = {
    enable = true,
    icons = {
      hint = shared_icons.hint,
      info = shared_icons.info,
      warning = shared_icons.warn,
      error = shared_icons.error,
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
  },
  on_attach = custom_on_attach
}

local function open_nvim_tree(data)
  -- buffer is a [No Name]
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

  -- buffer is a directory
  local directory = vim.fn.isdirectory(data.file) == 1

  if not no_name and not directory then
    return
  end

  -- change to the directory
  if directory then
    vim.cmd.cd(data.file)
  end

  -- open the tree
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "open menu when entering neovim",
  callback = open_nvim_tree
})

