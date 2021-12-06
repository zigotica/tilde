" NerdTree Setup

autocmd StdinReadPre * let s:std_in=1

" open a NERDTree automatically when vim starts up, if no files were specified, unless opening a saved session
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && v:this_session == "" | NERDTree | endif

" For mouse click in NERDTree
:set mouse=a
let g:NERDTreeMouseMode=3 

" hidden files
let NERDTreeShowHidden=1
let g:NERDTreeIgnore = ['^node_modules$[[dir]]', '^dist$[[dir]]', '^vendor$[[dir]]', '^build$[[dir]]', '^history$[[dir]]']

" Overwrite NERDTree colors
" (not in .cfg-colors.vim in case I eventually remove nerdtree)
hi NERDTreeCWD guifg=#97b87b ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeDir guifg=#97b87b ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeUp guifg=#7496b8 ctermfg=81 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi NERDTreeHelpTitle guifg=#c98b65 ctermfg=153 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
