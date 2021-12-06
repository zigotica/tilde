vim.cmd([[
source ~/.config/nvim/init.plugins.vim
for fpath in split(globpath('~/.config/nvim/', '.cfg-*'), '\n')
  exe 'source' fpath
endfor
]])

require("zigotica.settings")
require("zigotica.autocmds")
require("zigotica.plugins.bufferline")
require("zigotica.plugins.web-devicons")
require("zigotica.plugins.telescope")
require("zigotica.plugins.treesitter")
require("zigotica.plugins.colorizer")