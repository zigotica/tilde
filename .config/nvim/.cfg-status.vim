" show the status line all the time
set laststatus=2

" Since we are going to use lightline we dont need to show the mode in the line below
set noshowmode

" let lightline statusline plugin use gruvbox settings
let g:lightline = {}
let g:lightline.colorscheme = 'gruvbox'

" Custom overwrites:
" Add/modify the following in plugged/gruvbox/autload/lightline/gruvbox.vim
" let s:red = s:getGruvColor('GruvboxRed')
" let s:p.insert.left = [ [ s:bg0, s:red, 'bold' ], [ s:fg1, s:bg2 ] ]
" let s:p.insert.right = [ [ s:bg0, s:red ], [ s:fg1, s:bg2 ] ]
" let s:p.insert.middle = [ [ s:bg0, s:red ] ]

