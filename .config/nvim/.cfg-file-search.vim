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

" Allow real time search hightlight/replace
set inccommand=nosplit " remove hightlight pressing leader+esc, see remaps

" Set hidden allows the buffers to stay open while :cdo makes changes to each file in the quickfix buffer
set hidden

" Make Ag search from root of the project, not just current folder
let g:ag_working_path_mode="r"
