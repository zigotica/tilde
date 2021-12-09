" BASIC SETUP
" ---------------------------

set nocompatible " Use Vim settings, rather than Vi settings

set encoding=UTF-8

set title

set ttyfast " faster redrawing
set autoindent
set smartindent
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
set backspace=indent,eol,start " Allow backspacing over everything in INSERT mode

set noruler
set wrap " turn on line wrapping
set confirm

set ic
set cmdheight=1 " command bar height
set number relativenumber
set cursorline

" toggle invisible characters
set list
set listchars=tab:→\ ,eol:¬,trail:.

" Read file when modified outside Vim
set autoread 
" Above setting needs a bit of help
" also tmux config: set -g focus-events on
au FocusGained,BufEnter * :silent! !
au FocusLost,WinLeave * :silent! w

" Disables auto comment in new line
autocmd Filetype * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" allow system clipboard
set clipboard+=unnamedplus

" Splits opens at bottom or right unlike vim defaults
set splitbelow splitright

" Persistent history of changes
" You can use u (or :earlier 5m) to undo and CTRL R to redo
set undodir=~/.config/vim/history
set undofile
set undolevels=1000
set undoreload=1000

