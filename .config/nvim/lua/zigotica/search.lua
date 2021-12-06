-- FILE SEARCH SETUP
-- ---------------------------

-- enabling Plugin & Indent
vim.cmd([[
  filetype on
  filetype plugin on
  filetype indent on
]])

-- Search into subfolders, provides tab-completion
vim.opt.path = vim.opt.path + '**'

-- ignore folders from searches
vim.opt.wildignore  = vim.opt.wildignore + '*/node_modules/**,**/vendor/**,**/history/**'

-- display all matching files when we tab complete
-- - hit TAB to :find
-- - use * to make it fuzzy
-- - :b lets you autocomplete any open buffer (see buffer with :ls)
vim.opt.wildmenu = true

-- autocomplete on split, find, ...
vim.opt.wildmode = 'longest,list,full'

-- searching
vim.opt.ignorecase = true -- case insensitive searching
vim.opt.smartcase = true -- case-sensitive if expresson contains a capital letter
vim.opt.hlsearch = true -- highlight search results
vim.opt.incsearch = true -- set incremental search, like modern browsers

-- Allow real time search hightlight/replace
vim.opt.inccommand = 'nosplit' -- remove hightlight pressing leader+esc, see remaps

-- Set hidden allows the buffers to stay open while :cdo makes changes to each file in the quickfix buffer
vim.opt.hidden = true

