-- BASIC SETUP
-- ---------------------------

vim.opt.encoding = 'UTF-8'

vim.opt.title = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 0 
vim.opt.expandtab = true
vim.opt.shiftwidth = 2 
vim.opt.smarttab = true
vim.opt.backspace = 'indent,eol,start' -- Allow backspacing over everything in INSERT mode

vim.opt.ruler = false
vim.opt.wrap = true -- turn on line wrapping
vim.opt.confirm = true
vim.opt.showmode = false -- we are already showing mode info in status
vim.opt.laststatus = 3 -- use a single status line

-- allow mouse
vim.opt.mouse = 'a'

vim.opt.ic = true
vim.opt.cmdheight = 1 -- command bar height
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.guicursor = 'n-v:block,r-cr-o:hor30-blinkwait50-blinkon100-blinkoff50,i-ci-c-sm:ver30-blinkwait50-blinkon100-blinkoff50'

-- Read file when modified outside Vim
vim.opt.autoread = true
-- Above setting needs a bit of help
-- also tmux config: vim.opt.-g focus-events on
-- au FocusGained,BufEnter * :silent! !
-- au FocusLost,WinLeave * :silent! w

-- Disables auto comment in new line
-- autocmd Filetype * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

-- allow system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Splits opens at bottom or right unlike vim defaults
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Persistent history of changes
-- You can use u (or :earlier 5m) to undo and CTRL R to redo
vim.opt.undodir = vim.fn.expand('~/.config/nvim/history')
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 1000

-- folds using treesitter: zc (create) zo (open) zR (open all)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- keep them open by default
vim.opt.foldenable = false
