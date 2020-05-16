" show the status line all the time
set laststatus=2

" Since we are going to use lightline we dont need to show the mode in the line below
set noshowmode

" allow lightline statusline plugin use colorscheme
let g:lightline = {
      \ 'colorscheme': g:colors_name,
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'absolutepath', 'modified' ] ]
      \   },
      \ 'inactive': {
      \   'left': [ [ 'absolutepath', 'modified' ] ],
      \   'right': [ ]
      \   },
      \ }

