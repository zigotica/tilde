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
          hint = shared_icons.hint..' ',
          info = shared_icons.info..' ',
          warn = shared_icons.warn..' ',
          error = shared_icons.error..' ',
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
          modified = shared_icons.modified,
          readonly = shared_icons.readonly,
          unnamed = shared_icons.unnamed,
          newfile = shared_icons.newfile,
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
