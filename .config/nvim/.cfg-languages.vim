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
let g:python2_host_prog = '/usr/bin/python2.7'

" CSScomplete (improves the built in completion adding CSS3)
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS noci

