require("coverage").setup({
	auto_reload = true,
	commands = true, -- create commands
	signs = {
		covered = { hl = "DiagnosticOk", text = "." },
		uncovered = { hl = "DiagnosticError", text = "▎" },
		partial = { hl = "DiagnosticWarn", text = "▎" },
	},
	summary = {
		min_coverage = 80.0, -- customize the summary pop-up
	},
})

-- Keymaps
vim.keymap.set("n", "<leader>tc", '<cmd>lua require("coverage.summary").show()<CR>', { desc = "[T]est [C]overage" })
