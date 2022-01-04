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

map('n', '<leader>m', ':NvimTreeToggle<CR>') -- toggle Nerd Tree visibility

map('n', '<leader>x', ':!chmod +x %<CR>') -- make current file executable

map('n', '<leader>sv', ':source ~/.config/nvim/init.lua<CR>') -- source vim settings

-- SPECIAL CUT (d) / DELETE (x) MAPPINGS
-- Allows to copy text outside vim, delete in vim, paste copied text
-- If we want to paste deleted text we just add the leader before p/P
----------------------------------------------

map('n', 'd', '"1d') -- remap cut and delete to store text to register number 1
map('v', 'd', '"1d')
map('n', 'x', '"1x')
map('v', 'x', '"1x')
map('n', '<leader>p', '"1p') -- paste last deleted or cut text
map('n', '<leader>P', '"1P')

-- MOVE / INDENT MAPPINGS
----------------------------------------------

map('n', '<leader>k', ':m .-2<CR>==') -- move line up/down when in normal mode
map('n', '<leader>j', ':m .+1<CR>==')

map('i', '<c-k>', '<esc>:m .-2<CR>==gi') -- move line up/down when in insert mode
map('i', '<c-j>', '<esc>:m .+1<CR>==gi')

map('v', 'K', ":m '<-2<CR>gv=gv") -- move selected visual block up/down and reselect
map('v', 'J', ":m '>+1<CR>gv=gv")

map('v', '>', '>gv') -- indent visual block
map('v', '<', '<gv')


-- Keep things centered
----------------------------------------------

map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
map('n', 'J', 'mzJ`z') -- mark position, J (move next line to end of current line), move back to position


-- Undo breakpoints
----------------------------------------------

map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', '!', '!<c-g>u')
map('i', '[', '[<c-g>u')
map('i', '?', '?<c-g>u')
map('i', '{', '{<c-g>u')


-- TELESCOPE
----------------------------------------------

map('n', '<leader>sc', ':Telescope current_buffer_fuzzy_find <CR>') -- search content using fuzzy find in current buffer
map('n', '<leader>f',  ':Telescope find_files hidden=true no_ignore=true <CR>') -- search files using fuzzy find
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
