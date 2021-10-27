" COLORS
" ---------------------------


if (has("termguicolors"))
  set termguicolors
endif

if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

set t_Co=256

" colorscheme gruvbox         " 'morhetz/gruvbox'
" let g:gruvbox_contrast_dark='soft'

" colorscheme deus            " 'ajmwagar/vim-deus'
" colorscheme hybrid_material " 'kristijanhusak/vim-hybrid-material'
" colorscheme anderson        " 'tlhr/anderson.vim'
" colorscheme mod8            " 'easysid/mod8.vim'
colorscheme tender          " 'jacoborus/tender.vim'

" -----------------------------
" Helper to create new colorschemes
" Show syntax highlighting groups for word under cursor
" http://vimcasts.org/episodes/creating-colorschemes-for-vim/
" function! <SID>SynStack()
"   if !exists("*synstack")
"     return
"   endif
"   echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
" endfunc
" nmap <leader>sh :call <SID>SynStack()<CR>

