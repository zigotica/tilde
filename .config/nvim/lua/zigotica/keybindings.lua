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
map('n', 'Q', '<NOP>', {desc='Avoid Ex mode'})
map('', '<c-s>', ':w<CR>', {desc='[S]ave file'})
map('', '<F8>', ':setlocal spell! spelllang=en_gb<CR>', {desc='Toggle english spell checking'})
map('n', '<F9>', 'gg=G', {desc='Autoformat file'})
map('n', '<leader>=', ':lua vim.lsp.buf.format()<CR>', {desc='Autoformat file using LSP'})
map('v', '<F9>', '=', {desc='Autoformat visually selected block'})
map('n', '<ESC>', ':nohls<CR>', {desc='Remove search Highlight'})
map('n', '<leader>m', ':NvimTreeToggle<CR>', {desc='Toggle [M]emu'})
map('n', '<leader>x', ':!chmod +x %<CR>', {desc='Make current file e[X]ecutable'})

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
map('n', '<leader>p', '"1p', {desc='[p]aste last changed, deleted or cut text'})
map('n', '<leader>P', '"1P', {desc='[P]prepend last changed, deleted or cut text'})

-- MOVE / INDENT MAPPINGS
----------------------------------------------
map('n', '<leader>k', ':m .-2<CR>==', {desc='Move line up when in normal mode'})
map('n', '<leader>j', ':m .+1<CR>==', {desc='Move line down when in normal mode'})

map('i', '<c-k>', '<esc>:m .-2<CR>==gi', {desc='Move line up when in insert mode'})
map('i', '<c-j>', '<esc>:m .+1<CR>==gi', {desc='Move line down when in insert mode'})

map('v', 'K', ":m '<-2<CR>gv=gv", {desc='Move selected visual block up and reselect'})
map('v', 'J', ":m '>+1<CR>gv=gv", {desc='Move selected visual block down and reselect'})

map('v', '>', '>gv', {desc='Indent visual block'})
map('v', '<', '<gv', {desc='Outdent visual block'})


-- Undo breakpoints
----------------------------------------------
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', '!', '!<c-g>u')
map('i', '[', '[<c-g>u')
map('i', '?', '?<c-g>u')
map('i', '{', '{<c-g>u')


-- TELESCOPE / FUZZY FINDER
----------------------------------------------
map('n', '<leader>t', ':Telescope ', {desc='Show [T]elescope builtin pickers'})
map('n', '<leader>f', ':FzfLua files<CR>', {desc='[F]uzzy find files'})
map('n', '<leader>g', ':Telescope grep_string search=', {desc='[G]rep content'})
map('n', '<leader>b', ':Telescope buffers <CR>', {desc='[B]uffers'})
map('n', '<leader>u', ':Telescope undo<cr>', {desc='[U]ndo tree'})

-- BUFFERS
----------------------------------------------
map('n', '<leader>bc', ':%bd<CR>:e#<CR>:bd#<CR>:NvimTreeOpen<CR><C-w>l', {desc='[B]uffers [C]lose all but current'})

-- GIT
----------------------------------------------
map('n', '<leader>gb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>', {desc='[G]it [B]lame'})

-- TESTING
----------------------------------------------
map('n', '<leader>tr', '<cmd>lua require("neotest").run.run();require("neotest").summary.open()<CR>', {desc='[T]est [R]un'})
map('n', '<leader>ts', '<cmd>lua require("neotest").run.stop();require("neotest").summary.close()<CR>', {desc='[T]est [S]top'})
map('n', '<leader>tt', '<cmd>lua require("neotest").summary.toggle()<CR>', {desc='[T]est [T]oggle summary'})

-- SNIPPETS / EMMET expansions
----------------------------------------------
map('i', '<c-l>', '<cmd>lua require("luasnip").jump(-1)<CR>', { silent=true, desc='Luasnip jumop to prev insert position' })
map('i', '<c-n>', '<cmd>lua require("luasnip").jump(1)<CR>', { silent=true, desc='Luasnip jumop to next insert position' })
map('n', '<leader><leader>ee', '<plug>(emmet-expand-abbr)', {desc='[E]mmet [E]expand abbrv'})
map('i', '<c-e>e', '<plug>(emmet-expand-abbr)', {desc='[E]mmet [E]expand abbrv'})

-- AI
----------------------------------------------
map('n', '<leader>ai', ':Gen<CR>', {desc='[AI] menu'})
map('v', '<leader>ai', ':Gen<CR>', {desc='[AI] menu'})

-- REPLACEMENT
----------------------------------------------
-- (2x leader being a destructive command)
map('n', '<leader><leader>co', '<plug>(AvanteConflictOurs)', {desc='Avante [C]onflict, keep [O]riginal'})
map('n', '<leader><leader>ct', '<plug>(AvanteConflictTheirs)', {desc='Avante [C]onflict, keep [T]heirs'})
map('n', '<leader><leader>ca', '<plug>(AvanteConflictAllTheirs)', {desc='Avante [C]onflict, keep [A]ll Theirs'})

map('n', '<leader><leader>rf', ':%s/<C-r><C-w>//g<Left><Left>', {desc='[R]eplace word under cursor in [F]ile'})
map('v', '<leader><leader>rs', ':s///g<Left><Left><Left>', {desc='[R]eplace in [S]election'})
map('n', '<leader><leader>rb', ':bufdo %s/<C-r><C-w>//ge | update<C-Left><C-Left><Left><Left><Left><Left>', {desc='[R]eplace word under cursor in all open [B]uffers'})
map('n', '<leader><leader>rp', ':cdo %s/<C-r><C-w>//g<Left><Left>', {desc='[R]eplace word under cursor in [P]roject (requires quickfix buffer)'})
