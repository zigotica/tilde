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

" Overwrite NERDTree colors
" (not in .cfg-colors.vim in case I eventually remove nerdtree)
hi NERDTreeHelp guifg=#eeeeee ctermfg=255 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeHelpKey guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeHelpCommand guifg=#ffc24b ctermfg=215 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeHelpTitle guifg=#b3deef ctermfg=153 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeCWD guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeDir guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeUp guifg=#73cef4 ctermfg=81 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeOpenable guifg=#f43753 ctermfg=203 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeClosable guifg=#ffc24b ctermfg=215 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
