" Vim settings. 
" For neovim have a look at ~/.config/nvim
source ~/.config/vim/init.plugins.vim
for fpath in split(globpath('~/.config/vim/', '.cfg-*'), '\n')
  exe 'source' fpath
endfor

