require("colorizer").setup{
  '*';
}

local shared_palette = require"zigotica.common.colors"

-- Nightfox colorscheme overwrites
local palette = {
  nordfox = shared_palette,
}

local groups = {
  nordfox = {
    Normal = { fg = "palette.fg1", bg = "palette.bg1" },
    NormalNC = { fg = "palette.fg0", bg = "palette.bg0" },
    NvimTreeNormal = { fg = "palette.fg1", bg = "palette.crust" },
    NvimTreeFolderIcon = { fg = "palette.blue" },
    NvimTreeRootFolder = { fg = "palette.orange" },
    NvimTreeOpenedFile = { fg = "palette.orange" },
    NvimTreeSpecialFile = { fg = "palette.yellow" },
    DiagnosticError = { fg = "palette.red" },
    DiagnosticWarn = { fg = "palette.yellow" },
    DiagnosticInfo = { fg = "palette.fg1" },
    DiagnosticHint = { fg = "palette.blue" },
    DiagnosticOk = { fg = "palette.green" },
    LspFloatWinNormal = { bg = "palette.bg0" },
    BqfPreviewBorder = { bg = "palette.bg0" },
    BqfPreviewFloat = { bg = "palette.bg0" },
    WinSeparator = { fg = "palette.bg1", bg = "palette.bg0" },
    CursorLine = { bg = "palette.bg0" },
    NormalFloat = { bg = "palette.bg0" },
    FloatBorder = { fg = "palette.blue", bg = "palette.blue" },
  }
}

require("nightfox").setup({
  options = {
    transparent = true,     -- Disable setting background
    dim_inactive = true,
  },
  palettes = palette,
  groups = groups,
})


vim.cmd("colorscheme nordfox")
