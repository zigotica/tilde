source ~/.config/vim/init.plugins.vim
for fpath in split(globpath('~/.config/vim/', '.cfg-*'), '\n')
  exe 'source' fpath
endfor

