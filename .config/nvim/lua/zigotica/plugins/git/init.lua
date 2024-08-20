vim.cmd[[ highlight GitSignsAdd    guifg=#97b87b ]]
vim.cmd[[ highlight GitSignsChange guifg=#7496b8 ]]
vim.cmd[[ highlight GitSignsDelete guifg=#c98b65 ]]

require('gitsigns').setup{
  signs = {
    add          = {text = '+'},
    change       = {text = '~'},
    delete       = {text = '-'},
    topdelete    = {text = '‾'},
    changedelete = {text = '≃'},
  },
}
