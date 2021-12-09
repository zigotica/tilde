-- open a NERDTree automatically when
-- vim starts up, if no files were specified,
-- unless opening a saved session
vim.cmd([[
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && v:this_session == "" | NERDTree | endif
]])

-- mouse click in NERDTree
vim.g.NERDTreeMouseMode = 3 

-- hidden files
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeIgnore = {
  '^node_modules$[[dir]]',
  '^dist$[[dir]]',
  '^vendor$[[dir]]',
  '^build$[[dir]]',
  '^history$[[dir]]',
  '.DS_Store'
}

-- overwrite NERDTree colors
vim.cmd([[
  hi NERDTreeCWD guifg=#97b87b ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
  hi NERDTreeDir guifg=#97b87b ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
  hi NERDTreeUp guifg=#7496b8 ctermfg=81 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
  hi NERDTreeHelpTitle guifg=#c98b65 ctermfg=153 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
]])
