" gitgutter relies on the FocusGained event
let g:gitgutter_terminal_reports_focus=0

" add colors for git changes
hi GitGutterAdd guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi GitGutterChange guifg=#b3deef ctermfg=153 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi GitGutterDelete guifg=#f43753 ctermfg=203 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi GitGutterChangeDelete guifg=#f43753 ctermfg=203 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
