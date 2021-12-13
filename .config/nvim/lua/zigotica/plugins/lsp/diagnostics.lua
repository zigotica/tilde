-- Change diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- sort signs by severity (show most critical sign from those in the same line)
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    severity_sort = true
  }
)

-- Show line diagnostics in floating popup on hover, except insert mode (CursorHoldI)
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]]

-- Show source in diagnostics, not inline but as a floating popup
vim.diagnostic.config({
  virtual_text = false,
  float = {
    source = "always",  -- Or "if_many"
  },
})

-- create an array to hold custom border styles
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

-- modify open_floating_preview to use the custom borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
local open_floating_preview_custom = function(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
vim.lsp.util.open_floating_preview = open_floating_preview_custom

