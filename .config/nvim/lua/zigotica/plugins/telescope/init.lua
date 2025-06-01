local shared_icons = require("zigotica.common.icons")

require("telescope").setup({
	defaults = {
		prompt_prefix = " " .. shared_icons.search .. " ",
		sorting_strategy = "ascending",
		layout_config = {
			prompt_position = "top",
		},
		mappings = {
			i = {
				["<C-h>"] = "which_key",
			},
		},
		file_ignore_patterns = {
			"node_modules",
			"dist",
			"vendor",
			"build",
			"history",
			"plugged",
			".DS_Store",
		},
	},
	pickers = {
		find_files = {
			find_command = rg,
		},
		buffers = {
			mappings = { -- restore default Enter to open in same split
				n = {
					["<CR>"] = "select_default",
				},
				i = {
					["<CR>"] = "select_default",
				},
			},
		},
	},
	extensions = {
		glyph = {
			action = function(glyph)
				-- insert glyph when picked
				vim.api.nvim_put({ glyph.value }, "c", false, true)
			end,
		},
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				layout_config = {
					height = 22,
				},
			}),
		},
	},
})

require("telescope").load_extension("undo")
require("telescope").load_extension("glyph")
require("telescope").load_extension("ui-select")

require("fzf-lua").setup({
	files = { fzf_opts = { ["--ansi"] = false } },
	defaults = { git_icons = false, file_icons = false },
	grep = {
		fzf_opts = { ["--ansi"] = false },
		grep_opts = require("fzf-lua.utils").is_darwin()
				and "--color=never --binary-files=without-match --line-number --recursive --extended-regexp -e"
			or "--color=never --binary-files=without-match --line-number --recursive --perl-regexp -e",
		rg_opts = " --color=never --column --line-number --no-heading --smart-case --max-columns=4096 -e",
	},
})

require("telescope").load_extension("docker_commands")
require("docker_commands").setup({})
vim.keymap.set("n", "<leader>dk", ":Telescope docker_commands<CR>", { desc = "[D]oc[K]er actions picker" })
