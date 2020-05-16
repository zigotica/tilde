" PLUGINS
" ---------------------------

" Specify a directory for plugins
call plug#begin('~/.config/nvim/plugged')

" Specifiy plugins, in single quotes
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'airblade/vim-gitgutter'
Plug 'zivyangll/git-blame.vim'
Plug 'vim-syntastic/syntastic'
Plug 'mattn/emmet-vim'
Plug 'Chiel92/vim-autoformat'
Plug 'rking/ag.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'editorconfig/editorconfig-vim'
Plug 'AndrewRadev/tagalong.vim'
Plug 'othree/csscomplete.vim'

Plug 'itchyny/lightline.vim' " status line color tweaks

Plug 'morhetz/gruvbox'
Plug 'tlhr/anderson.vim'
Plug 'ajmwagar/vim-deus'
Plug 'jacoborus/tender.vim'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'easysid/mod8.vim'

" Initialize plugin system
call plug#end()
 

