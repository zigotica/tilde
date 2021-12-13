vim.cmd([[
" ripped off from https://github.com/wincent/wincent just simplified & renames
let g:WincentColorColumnBufferNameBlacklist = ['__LanguageClient__']
let g:WincentColorColumnFileTypeBlacklist = ['command-t', 'diff', 'dirvish', 'fugitiveblame', 'nerdtree', 'undotree', 'qf']
let g:WincentCursorlineBlacklist = ['command-t']

function! ShouldColor() abort
  if index(g:WincentColorColumnBufferNameBlacklist, bufname(bufnr('%'))) != -1
    return 0
  endif
  return index(g:WincentColorColumnFileTypeBlacklist, &filetype) == -1
endfunction

function! ShouldCursorline() abort
  return index(g:WincentCursorlineBlacklist, &filetype) == -1
endfunction

function! BlurBuffer() abort
  if ShouldColor()
    ownsyntax off
  endif
endfunction

function! FocusBuffer() abort
  if ShouldColor()
    if !empty(&ft)
      ownsyntax on
    endif
  endif
endfunction

autocmd BufEnter,FocusGained,VimEnter,WinEnter * call FocusBuffer()
autocmd FocusLost,WinLeave * call BlurBuffer()

" save file on blur
autocmd FocusLost,WinLeave * silent! :wa

" When entering insert mode, relative line numbers are turned off
" Same when the buffer loses focus
" see https://jeffkreeftmeijer.com/vim-number/
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
:augroup END
]])
