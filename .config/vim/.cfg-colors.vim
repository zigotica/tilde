" COLORS
" ---------------------------

set t_Co=256
if (has("termguicolors"))
  set termguicolors
endif

syntax enable
set bg=dark
colorscheme gruvbox

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

