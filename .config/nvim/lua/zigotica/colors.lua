vim.opt.termguicolors = true

vim.cmd([[
  syntax enable
  colorscheme Nordfox
]])

-- -----------------------------
-- Helper to create new colorschemes
-- Show syntax highlighting groups for word under cursor
-- http://vimcasts.org/episodes/creating-colorschemes-for-vim/
-- function! <SID>SynStack()
--   if !exists("*synstack")
--     return
--   endif
--   echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
-- endfunc
-- nmap <leader>sh :call <SID>SynStack()<CR>
