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
-- mapleader defined just before the plugins are listed, lazy.nvim depends on it
-- map('n', '<Space>', '<NOP>', { silent = true })
-- vim.g.mapleader = ' '

map('n', 'Q', '<NOP>') -- dont use Ex mode

map('', '<F1>', ':w<CR>') -- save file

map('n', '<F2>', ':vertical resize -2<CR>') -- resize vertical splits
map('n', '<F3>', ':vertical resize +2<CR>')

map('n', '<F4>', ':<C-w>h') -- navigate vertical splits
map('n', '<F5>', ':<C-w>l')

map('', '<F8>', ':setlocal spell! spelllang=en_gb<CR>') -- toggle english spell checking

map('n', '<F9>', 'gg=G') -- autoformat file
map('v', '<F9>', '=') -- autoformat visually selected block

map('n', '<leader>h', ':nohls<CR>') -- remove search highlight

map('n', '<leader>m', ':NvimTreeToggle<CR>') -- toggle NVimTree visibility

map('n', '<leader>x', ':!chmod +x %<CR>') -- make current file executable

-- SPECIAL CHANGE (c) / CUT (d) / DELETE (x) MAPPINGS
-- Allows to copy text outside vim, delete in vim, paste copied text
-- If we want to paste deleted text we just add the leader before p/P
----------------------------------------------

map('n', 'd', '"1d') -- remap change, cut and delete to store text to register number 1
map('n', 'D', '"1D')
map('v', 'd', '"1d')
map('n', 'c', '"1c')
map('n', 'C', '"1C')
map('v', 'c', '"1c')
map('n', 'x', '"1x')
map('v', 'x', '"1x')
map('n', '<leader>p', '"1p') -- paste last changed, deleted or cut text
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

map('n', '<leader>t', ':Telescope ') -- Show telescope builtin pickers (press Tab)
map('n', '<leader>f',  ':Telescope find_files hidden=true no_ignore=true <CR>') -- search files using fuzzy find
map('n', '<leader>g',  ':Telescope grep_string search=') -- grep content and send results to a list that can be fzf'ed
map('n', '<leader>b',  ':Telescope buffers <CR>') -- search files within open buffers, using fuzzy find


-- BUFFERS
----------------------------------------------

-- Close all buffers except the one being edited
-- We also also close all possible remaining splits
-- Finally, open NvimTree and focus on the open buffer
map('n', '<leader>bc', ':%bd<CR>:e#<CR>:bd#<CR>:NvimTreeOpen<CR><C-w>l')


-- GIT
----------------------------------------------

map('n', '<leader>gb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>') -- git blame for line


-- REPLACEMENT
----------------------------------------------
-- (2x leader being a destructive command)

map('n', '<leader><leader>ee', '<plug>(emmet-expand-abbr)') -- emmet expand abbrv
map('i', '<c-e>e', '<plug>(emmet-expand-abbr)') 

map('n', '<leader><leader>rf', ':%s/<C-r><C-w>//g<Left><Left>') -- replace word under cursor in file
map('v', '<leader><leader>rs', ':s///g<Left><Left><Left>') -- replace in selection
map('n', '<leader><leader>rb', ':bufdo %s/<C-r><C-w>//ge | update<C-Left><C-Left><Left><Left><Left><Left>') -- replace word under cursor in all open buffers
map('n', '<leader><leader>rp', ':cdo %s/<C-r><C-w>//g<Left><Left>') -- replace word under cursor in all project (requires a quickfix buffer from a search, like :rg)
