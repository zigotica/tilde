" LANGUAGES (autocompletion, etc)
" ------------------------------------

" COC Setup
let g:coc_global_extensions = [
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-json',
  \ 'coc-sh',
  \ 'coc-emmet',
  \ ]

" Emmet Setup
" CTRL y, to expand the template
" or :Emmet template ENTER
let g:user_emmet_mode='a' "enable all function in all mode
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

" needed for autoformat
let g:python_version = matchstr(system("python --version | cut -f2 -d' '"), '^[0-9]')
if g:python_version =~ 2
    let g:python2_host_prog = "/usr/local/bin/python2"
else
    let g:python3_host_prog = "/Users/zgtc/.pyenv/shims/python"
endif

" CSScomplete (improves the built in completion adding CSS3)
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS noci

