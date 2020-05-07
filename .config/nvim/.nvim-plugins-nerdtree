" NerdTree Setup

autocmd StdinReadPre * let s:std_in=1

" open a NERDTree automatically when vim starts up, if no files were specified, unless opening a saved session
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && v:this_session == "" | NERDTree | endif

" For mouse click in NERDTree
:set mouse=a
let g:NERDTreeMouseMode=3 

" hidden files
let NERDTreeShowHidden=1
let g:NERDTreeIgnore = ['^node_modules$[[dir]]', '^dist$[[dir]]', '^vendor$[[dir]]', '^build$[[dir]]']

" other
let NERDTreeDirArrowExpandable = "\u00a0" " make arrows invisible instead '▷'
let NERDTreeDirArrowCollapsible = "\u00a0" " make arrows invisible instead '▼'
