" PLUGINS
" ---------------------------

" Specify a directory for plugins
call plug#begin('~/.config/nvim/plugged')

" Basic extensions
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'editorconfig/editorconfig-vim'
Plug 'AndrewRadev/tagalong.vim'

" Menu 
Plug 'scrooloose/nerdtree'

" Search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" Telescope core
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'zivyangll/git-blame.vim'

" Languages
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'vim-syntastic/syntastic'
Plug 'mattn/emmet-vim'
Plug 'Chiel92/vim-autoformat'
Plug 'othree/csscomplete.vim'
Plug 'neoclide/coc-tabnine'

" Status
Plug 'itchyny/lightline.vim'

" Colorschemes
Plug 'jacoborus/tender.vim'

" Initialize plugin system
call plug#end()
 

