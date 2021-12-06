" gitgutter relies on the FocusGained event
let g:gitgutter_terminal_reports_focus=0

" add colors for git changes
hi GitGutterAdd guifg=#97b87b ctermfg=115 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi GitGutterChange guifg=#7496b8 ctermfg=33 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi GitGutterDelete guifg=#bf5454 ctermfg=198 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi GitGutterChangeDelete guifg=#bf5454 ctermfg=198 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
