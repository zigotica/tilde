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

" CSScomplete (improves the built in completion adding CSS3)
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS noci
autocmd FileType scss setlocal iskeyword+=@-@

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    \ "bash",
    \ "css",
    \ "scss",
    \ "html",
    \ "json",
    \ "javascript",
    \ "typescript",
    \ "tsx",
    \ "yaml",
    \ "lua",
  \ },
  sync_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
EOF

