source ~/.config/nvim/init.plugins.vim
for fpath in split(globpath('~/.config/nvim/', '.cfg-*'), '\n')
  exe 'source' fpath
endfor

