local palette = require"zigotica.common.colors"
local shared_icons = require"zigotica.common.icons"

require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = {
      normal = {
        a = { bg = palette.bg0, fg = palette.fg1 },
        b = { bg = palette.bg0, fg = palette.fg1 },
        c = { bg = palette.bg0, fg = palette.fg1 },
        x = { bg = palette.bg0, fg = palette.fg1 },
        y = { bg = palette.bg0, fg = palette.fg1 },
        z = { bg = palette.bg0, fg = palette.fg1 },
      },
      insert = {
        a = { bg = palette.bg0, fg = palette.green },
        b = { bg = palette.green, fg = palette.black },
        c = { bg = palette.green, fg = palette.black },
        x = { bg = palette.green, fg = palette.black },
        y = { bg = palette.green, fg = palette.black },
        z = { bg = palette.bg0, fg = palette.green },
      },
      command = {
        a = { bg = palette.bg0, fg = palette.yellow },
        b = { bg = palette.yellow, fg = palette.black },
        c = { bg = palette.yellow, fg = palette.black },
        x = { bg = palette.yellow, fg = palette.black },
        y = { bg = palette.yellow, fg = palette.black },
        z = { bg = palette.bg0, fg = palette.yellow },
      },
      visual = {
        a = { bg = palette.bg0, fg = palette.blue },
        b = { bg = palette.blue, fg = palette.black },
        c = { bg = palette.blue, fg = palette.black },
        x = { bg = palette.blue, fg = palette.black },
        y = { bg = palette.blue, fg = palette.black },
        z = { bg = palette.bg0, fg = palette.blue },
      },
      replace = {
        a = { bg = palette.bg0, fg = palette.red },
        b = { bg = palette.red, fg = palette.black },
        c = { bg = palette.red, fg = palette.black },
        x = { bg = palette.red, fg = palette.black },
        y = { bg = palette.red, fg = palette.black },
        z = { bg = palette.bg0, fg = palette.red },
      },
      inactive = {
        a = { bg = palette.bg0, fg = palette.fg1 },
        b = { bg = palette.bg0, fg = palette.fg1 },
        c = { bg = palette.bg0, fg = palette.fg1 },
        x = { bg = palette.bg0, fg = palette.fg1 },
        y = { bg = palette.bg0, fg = palette.fg1 },
        z = { bg = palette.bg0, fg = palette.fg1 },
      },
    },
    component_separators = { left = '|', right = ''}, --   
    section_separators = { left = '', right = ''}, --      
    disabled_filetypes = {},
    always_divide_middle = false,
  },
  sections = {
    lualine_a = {
      {'branch'},
      {'diff'},
      {
        'diagnostics',
        source = {'nvim_lsp', 'nvim_diagnostic'},
        symbols = {
          hint = shared_icons[1]..' ',
          info = shared_icons[2]..' ',
          warn = shared_icons[3]..' ',
          error = shared_icons[4]..' ',
        },
      },
    },
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        file_status = true,
        newfile_status = true,
        path = 1,
        symbols = {
          modified = shared_icons[5],
          readonly = shared_icons[6],
          unnamed = shared_icons[7],
          newfile = shared_icons[8],
        }
      },
    },
    lualine_x = {{'fileformat'},{'encoding'}},
    lualine_y = {{'location'},{'progress'}},
    lualine_z = {'mode'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = { 'lazy', 'nvim-tree' }
}
