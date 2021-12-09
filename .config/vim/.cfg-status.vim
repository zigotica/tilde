" show the status line all the time
set laststatus=2

" Since we are going to use lightline we dont need to show the mode in the line below
set noshowmode

" allow lightline statusline plugin use colorscheme
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'relativepath', 'modified' ] ]
      \   },
      \ 'inactive': {
      \   'left': [ [ 'filename', 'modified' ] ],
      \   'right': [ ]
      \   },
      \ }

