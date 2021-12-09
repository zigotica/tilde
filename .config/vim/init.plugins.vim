" PLUGINS
" ---------------------------

" Specify a directory for plugins
call plug#begin('~/.config/vim/plugged')

" Basic extensions
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'editorconfig/editorconfig-vim'
Plug 'AndrewRadev/tagalong.vim'

" Menu 
Plug 'scrooloose/nerdtree'

" Search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'rking/ag.vim'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'zivyangll/git-blame.vim'

" Languages
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" after :PlugInstall, run :CocInstall coc-eslint coc-tsserver coc-json coc-html coc-css coc-sh coc-tabnine
" also :CocCommand eslint.showOutputChannel
Plug 'sheerun/vim-polyglot'
Plug 'vim-syntastic/syntastic'
Plug 'mattn/emmet-vim'
Plug 'othree/csscomplete.vim'
Plug 'neoclide/coc-tabnine'

" Status
Plug 'itchyny/lightline.vim'

" Colorschemes
Plug 'morhetz/gruvbox'

" Initialize plugin system
call plug#end()
 

