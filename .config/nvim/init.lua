vim.cmd([[
source ~/.config/nvim/init.plugins.vim
for fpath in split(globpath('~/.config/nvim/', '.cfg-*'), '\n')
  exe 'source' fpath
endfor
]])

require("zigotica.settings")
require("zigotica.bufferline")
require("zigotica.web-devicons")
require("zigotica.telescope")
require("zigotica.treesitter")
require("zigotica.colorizer")
