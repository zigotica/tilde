-- Setup lspconfig server languages

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- enable inlay hints if server supports it, but hidden by default
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(false, { buffer = bufnr })
    -- else
    -- 	print("inlay hints not supported by " .. client.name)
  end

  -- buffer LSP related keymaps
  local opts = { buffer = bufnr }
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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>F", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local servers = {
  "ansiblels",
  "awk_ls",
  "bashls",
  "ccls",
  "cssls",
  "css_variables",
  "eslint",
  "gopls",
  "html",
  "jsonls",
  "lua_ls",
  "rust_analyzer",
  "vuels",
  "ts_ls",
  "yaml_ls",
  "gitlab_cs_ls",
}

for _, server_name in ipairs(servers) do
  vim.lsp.config(server_name, {
    capabilities = capabilities,
    on_attach = on_attach,
  })
  vim.lsp.enable(server_name)
end

-- specific settings for lua server
vim.lsp.config("lua_ls", {
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

-- specific settings for yaml server
vim.lsp.config("yaml_ls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml", "yaml.ansible", "yaml.gitlab" },
  settings = {
    yaml = {
      schemaStore = {
        enable = true, -- allow server to fetch schema catalog
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      schemas = {},
      validate = true,
      hover = true,
      completion = true,
      format = { enable = true },
      keyOrdering = false,
    },
  },
})

-- specific settings for gitlab_cs server
vim.lsp.config("gitlab_cs_ls", {
  cmd = { "gitlab-ci-ls" },
})

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

vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      inlayHints = inlayHints,
    },
    javascript = {
      inlayHints = inlayHints,
    },
  },
})

-- toggle inlay hints
if vim.lsp.inlay_hint then
  vim.keymap.set("n", "<leader>h", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, { desc = "Toggle Inlay [H]ints" })
end
