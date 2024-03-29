" FILE SEARCH SETUP
" ---------------------------

" enabling Plugin & Indent
filetype on
filetype plugin on
filetype indent on

" Search into subfolders, provides tab-completion
set path+=**

" ignore folders from searches
set wildignore+=**/node_modules/**,**/vendor/**

" display all matching files when we tab complete
" - hit TAB to :find
" - use * to make it fuzzy
" - :b lets you autocomplete any open buffer (see buffer with :ls)
set wildmenu

" autocomplete on split, find, ...
set wildmode=longest,list,full

" searching
set ignorecase " case insensitive searching
set smartcase " case-sensitive if expresson contains a capital letter
set hlsearch " highlight search results
set incsearch " set incremental search, like modern browsers

" Set hidden allows the buffers to stay open while :cdo makes changes to each file in the quickfix buffer
set hidden

" FZF popup
let g:fzf_preview_window = ['right:40%', 'ctrl-/']
let g:fzf_buffers_jump = 1
