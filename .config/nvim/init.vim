source ~/.config/nvim/init.plugins
for fpath in split(globpath('~/.config/nvim/', '.nvim-*'), '\n')
  exe 'source' fpath
endfor