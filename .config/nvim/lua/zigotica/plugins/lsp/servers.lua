-- Setup lspconfig server languages

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- buffer LSP related keymaps
  local opts = { buffer = 0 }
  -- show info on symbol under the cursor on hover window
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  -- go to definition (CTRL + T to jump back)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  -- go to next/prev diagnostic (error, warning, ...)
  vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, opts)
  -- show diagnostic for all files in fzf list (CTRL + Q to send to quicklist)
  vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<CR>", opts)
  -- code actions
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  -- rename symbol
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)

  -- Enable completion in insert mode, triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- setup servers from the list
local servers = {
  'ansiblels',
  'bashls',
  'cssls',
  'eslint',
  'html',
  'jsonls',
  'rust_analyzer',
  'tsserver',
  'vuels',
}

for _, server in ipairs(servers) do
  require'lspconfig'[server].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

