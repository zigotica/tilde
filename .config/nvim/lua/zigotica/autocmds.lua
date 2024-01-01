vim.api.nvim_create_autocmd('TextYankPost', {
  desc = "Briefly highlight yanked text",
  callback = function() vim.highlight.on_yank{higroup="IncSearch", timeout=400} end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Avoid folds inside Telesope picker",
  pattern = "TelescopeResults",
  command = [[setlocal nofoldenable]],
})

vim.api.nvim_create_autocmd("FocusLost,WinLeave", {
  desc = "Save files on blur",
  pattern = "*",
  command = "silent! :wa",
})

vim.api.nvim_create_autocmd("BufRead,BufNewFile", {
  desc = "Interpret inventory files as an Ansible inventory",
  pattern = "*/**/inventory",
  command = "set filetype=yaml.ansible",
})

