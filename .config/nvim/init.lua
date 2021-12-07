vim.cmd([[
source ~/.config/nvim/init.plugins.vim
for fpath in split(globpath('~/.config/nvim/', '.cfg-*'), '\n')
  exe 'source' fpath
endfor
]])

require("zigotica.colors")
require("zigotica.settings")
require("zigotica.autocmds")
require("zigotica.search")
require("zigotica.keybindings")
require("zigotica.plugins.bufferline")
require("zigotica.plugins.web-devicons")
require("zigotica.plugins.telescope")
require("zigotica.plugins.lsp")
require("zigotica.plugins.treesitter")
require("zigotica.plugins.colorizer")
require("zigotica.plugins.lualine")

