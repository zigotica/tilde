require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'nightfox',
    component_separators = { left = '|', right = ''}, --   
    section_separators = { left = '', right = ''}, --      
    disabled_filetypes = {},
    always_divide_middle = false,
  },
  sections = {
    lualine_a = {{'branch'}, {'diff'},{'diagnostics', sources={'nvim_lsp', 'nvim_diagnostic'}}},
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 1,
        symbols = {
          modified = '*', -- 󰅸 * 
          readonly = '󰌾',
          unnamed = '',
          newfile = '',
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
