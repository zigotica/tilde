-- Change diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Show line diagnostics automatically in hover window, except insert mode (CursorHoldI)
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]]

-- Show source in diagnostics, not inline but as a floating popup
vim.diagnostic.config({
  virtual_text = false,
  float = {
    source = "always",  -- Or "if_many"
  },
})

-- diagnostic border
vim.cmd [[autocmd ColorScheme * highlight LspFloatWinNormal guibg=#242220]]
vim.cmd [[autocmd ColorScheme * highlight LspFloatWinBorder guifg=red guibg=#242220]]

local border = {
      {"🭽", "LspFloatWinBorder"},
      {"▔", "LspFloatWinBorder"},
      {"🭾", "LspFloatWinBorder"},
      {"▕", "LspFloatWinBorder"},
      {"🭿", "LspFloatWinBorder"},
      {"▁", "LspFloatWinBorder"},
      {"🭼", "LspFloatWinBorder"},
      {"▏", "LspFloatWinBorder"},
}

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
