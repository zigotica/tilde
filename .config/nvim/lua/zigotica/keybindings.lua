-- Map method to handle the different kind of key maps
-- https://www.imaginaryrobots.net/2021/04/17/converting-vimrc-to-lua
local function map(mode, combo, mapping, opts)
  local options = {noremap = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, combo, mapping, options)
end

-- GENERAL MAPPINGS
----------------------------------------------

map('n', '<Space>', '<NOP>', { silent = true })
vim.g.mapleader = ' '

map('', '<F1>', ':help<CR>') -- help

map('n', '<F2>', 'gg=G') -- autoformat file, normal mode
map('v', '<F2>', '=') -- autoformat file, visual mode

map('n', '<F3>', ':resize +2<CR>') -- resize horizontal split
map('n', '<F4>', ':resize -2<CR>')

map('n', '<F5>', ':<C-w>h') -- navigate vertical splits
map('n', '<F6>', ':<C-w>l')

map('n', '<F7>', ':vertical resize -2<CR>') -- resize vertical split
map('n', '<F8>', ':vertical resize +2<CR>')

map('', '<F10>', ':w<CR>') -- save file

map('', '<F12>', ':setlocal spell! spelllang=en_gb<CR>') -- toggle english spell checking

map('n', '<leader>h', ':nohls<CR>') -- remove search highlight

map('n', 'Q', '<NOP>') -- dont use Ex mode

map('n', '<leader>m', ':NERDTreeToggle<CR>') -- toggle Nerd Tree visibility
map('n', '<leader>sf', ':NERDTreeFind<CR>', { silent = true }) -- show file in enclosing folder

map('n', '<leader>x', ':!chmod +x %<CR>') -- make current file executable

map('n', '<leader>sv', ':source ~/.config/nvim/init.lua<CR>') -- source vim settings


-- VISUAL MODE MAPPINGS
----------------------------------------------

-- move selected blocks
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

-- indent
map('v', '>', '>gv')
map('v', '<', '<gv')


-- TELESCOPE
----------------------------------------------

map('n', '<leader>sc', ':Telescope current_buffer_fuzzy_find <CR>') -- search content using fuzzy find in current buffer
map('n', '<leader>ff', ':Telescope find_files <CR>') -- search files using fuzzy find
map('n', '<leader>g',  ':Telescope grep_string search=') -- grep content and send results to a list that can be fzf'ed
map('n', '<leader>b',  ':Telescope buffers <CR>') -- search files within open buffers, using fuzzy find


-- BUFFERS
----------------------------------------------

-- Close all buffers except the one being edited
-- We also also close all possible remaining splits
-- Finally, open NERDTree but focus on the file
map('n', '<leader>bc', ':%bd<CR>:e#<CR>:bd#<CR>:NERDTree<CR><C-w>l')


-- GIT
----------------------------------------------

map('n', '<leader>gb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>') -- git blame for line


-- REPLACEMENT
----------------------------------------------
-- (2x leader being a destructive command)

map('n', '<leader><leader>rf', ':%s/a/b/g') -- replace in file
map('n', '<leader><leader>rb', ':bufdo %s/a/b/ge | update') -- replace in all open buffers
map('n', '<leader><leader>rp', ':cdo %s/a/b/g') -- replace in all project (requires a quickfix buffer from a search, like :rg)
