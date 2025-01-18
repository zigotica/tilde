-- Setup lspconfig server languages

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- enable inlay hints if server supports it
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { buffer = bufnr })
  else
    print("inlay hints not supported by " .. client.name)
  end

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
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
end

local common_config = {
  capabilities = capabilities,
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
}

-- setup servers from the list
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local servers = {
  "ansiblels",
  "awk_ls",
  "bashls",
  "ccls",
  "cssls",
  "eslint",
  "gopls",
  "html",
  "jsonls",
  "rust_analyzer",
  "vuels",
}

for _, server in ipairs(servers) do
  require("lspconfig")[server].setup(common_config)
end

-- specific settings for lua server
local lua_settings = vim.tbl_extend('force', common_config, {
  settings = {
    Lua = {
      -- require lua server from source, not brew version
      -- https://luals.github.io/#neovim-install
      hint = { enable = true },
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})
require("lspconfig").lua_ls.setup(lua_settings)

-- specific settings for typescript server
local inlayHints = {
  includeInlayParameterNameHints = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}
local ts_settings = vim.tbl_extend('force', common_config, {
  settings = {
    typescript = {
      inlayHints = inlayHints,
    },
    javascript = {
      inlayHints = inlayHints,
    },
  },
})
require("lspconfig").ts_ls.setup(ts_settings)

-- toggle inlay hints
if vim.lsp.inlay_hint then
  vim.keymap.set('n', '<leader>h', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { buffer = bufnr })
  end, { desc = 'Toggle Inlay [H]ints' })
end
