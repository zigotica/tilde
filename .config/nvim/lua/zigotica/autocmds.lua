vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Briefly highlight yanked text",
  callback = function() vim.highlight.on_yank{higroup="IncSearch", timeout=400} end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Avoid folds inside Telesope picker",
  pattern = "TelescopeResults",
  command = [[setlocal nofoldenable]],
})

vim.api.nvim_create_autocmd({"FocusLost","WinLeave"}, {
  desc = "Save files on blur",
  pattern = "*",
  command = "silent! :wa",
})

vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
  desc = "Interpret .code-snippets files as JSON",
  pattern = "*.code-snippets",
  command = "set filetype=json",
})

vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
  desc = "Interpret inventory files as an Ansible inventory",
  pattern = "*/**/inventory",
  command = "set filetype=yaml.ansible",
})

vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
  desc = "Interpret yml files inside a playbooks folder as Ansible files",
  pattern = "*/playbooks/*.yml",
  command = "set filetype=yaml.ansible",
})

-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({async = false})
  end
})

