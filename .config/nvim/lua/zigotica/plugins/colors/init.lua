require("colorizer").setup({
	"*",
	css = {
		css = true, -- Enable all CSS features
	},
	scss = {
		css = true, -- Enable all CSS features
	},
})

local shared_palette = require("zigotica.common.colors")

-- Nightfox colorscheme overwrites
local palette = {
  nordfox = shared_palette,
}

local groups = {
  nordfox = {
    -- UI elements
    Normal = { fg = "palette.fg1", bg = "palette.bg1" },
    NormalNC = { fg = "palette.fg0", bg = "palette.bg0" },
    NormalFloat = { bg = "palette.bg0" },
    FloatBorder = { fg = "palette.blue", bg = "palette.blue" },
    CursorLine = { bg = "palette.bg0" },
    WinSeparator = { fg = "palette.bg1", bg = "palette.bg0" },

    -- NvimTree
    NvimTreeNormal = { fg = "palette.fg1", bg = "palette.crust" },
    NvimTreeFolderIcon = { fg = "palette.blue" },
    NvimTreeRootFolder = { fg = "palette.orange" },
    NvimTreeOpenedFile = { fg = "palette.orange" },
    NvimTreeSpecialFile = { fg = "palette.yellow" },

    -- Diagnostics
    DiagnosticError = { fg = "palette.red" },
    DiagnosticWarn = { fg = "palette.yellow" },
    DiagnosticInfo = { fg = "palette.fg1" },
    DiagnosticHint = { fg = "palette.blue" },
    DiagnosticOk = { fg = "palette.green" },

    -- LSP & BQF
    LspFloatWinNormal = { bg = "palette.bg0" },
    BqfPreviewBorder = { bg = "palette.bg0" },
    BqfPreviewFloat = { bg = "palette.bg0" },

    -- Avante
    AvanteSubtitle = { fg = "palette.bg1", bg = "palette.cyan" },
    AvanteReversedSubtitle = { fg = "palette.cyan" },
    AvanteTitle = { fg = "palette.bg1", bg = "palette.green" },
    AvanteReversedTitle = { fg = "palette.green" },
    AvanteThirdTitle = { fg = "palette.fg1", bg = "palette.bg0" },
    AvanteReversedThirdTitle = { fg = "palette.bg0" },
    AvantePopupHint = { link = "NormalFloat" },
    AvanteAnnotation = { link = "Comment" },
    AvanteSuggestion = { link = "Comment" },
    AvanteInlineHint = { link = "Keyword" },
    AvanteConflictAncestorLabel = { bg = "palette.red" },
    AvanteConflictAncestor = { bg = "palette.red", style = "bold" },
    AvanteConflictIncomingLabel = { fg = "palette.bg1", bg = "palette.green" },
    AvanteConflictIncoming = { link = "Normal" },
    AvanteConflictCurrentLabel = { bg = "palette.orange" },
    AvanteConflictCurrent = { link = "Normal" },
  },
}

require("nightfox").setup({
  options = {
    transparent = true, -- Disable setting background
    dim_inactive = true,
  },
  palettes = palette,
  groups = groups,
})

vim.cmd("colorscheme nordfox")
