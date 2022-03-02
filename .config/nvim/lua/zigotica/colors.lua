vim.opt.termguicolors = true

vim.cmd([[
  syntax enable
  colorscheme nordfox
]])


-- syntax highlighting for some languages in markdown code blocks
vim.g.markdown_fenced_languages = {
  "bash",
  "css", "scss",
  "html",
  "javascript", "typescript",
  "json",
  "lua",
  "vim"
}

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
