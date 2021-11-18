local colors = require("nightfox.colors").load()

local nightfox = {}

nightfox.normal = {
  -- zigotica:
  left = { { colors.black, colors.fg }, { colors.fg, colors.bg_highlight } },
  middle = { { colors.black, colors.fg }, { colors.fg, colors.bg_highlight } },
  right = { { colors.black, colors.fg }, { colors.fg, colors.bg_highlight } },
  -- left = { { colors.black, colors.blue }, { colors.blue, colors.bg } },
  -- middle = { { colors.blue, colors.fg_gutter } },
  -- right = { { colors.fg_sidebar, colors.bg_statusline }, { colors.blue, colors.bg } },
  error = { { colors.black, colors.error } },
  warning = { { colors.black, colors.warning } },
}

nightfox.insert = {
  -- zigotica:
  left = { { colors.black, colors.green }, { colors.green, colors.bg_highlight } },
  middle = { { colors.black, colors.green }, { colors.green, colors.bg_highlight } },
  right = { { colors.black, colors.green }, { colors.green, colors.bg_highlight } },
  -- left = { { colors.black, colors.green }, { colors.blue, colors.bg } },
}

nightfox.visual = {
  -- zigotica:
  left = { { colors.black, colors.blue }, { colors.blue, colors.bg_highlight } },
  middle = { { colors.black, colors.blue }, { colors.blue, colors.bg_highlight } },
  right = { { colors.black, colors.blue }, { colors.blue, colors.bg_highlight } },
  -- left = { { colors.black, colors.magenta }, { colors.blue, colors.bg } },
}

nightfox.replace = {
  -- zigotica:
  left = { { colors.black, colors.red }, { colors.red, colors.bg_highlight } },
  middle = { { colors.black, colors.red }, { colors.red, colors.bg_highlight } },
  right = { { colors.black, colors.red }, { colors.red, colors.bg_highlight } },
  -- left = { { colors.black, colors.red }, { colors.blue, colors.bg } },
}

nightfox.inactive = {
  -- left = { { colors.blue, colors.bg_statusline }, { colors.comment, colors.bg } },
  -- middle = { { colors.fg_gutter, colors.bg_statusline } },
  -- right = { { colors.fg_gutter, colors.bg_statusline }, { colors.comment, colors.bg } },
  -- zigotica:
  left = { { colors.comment, colors.bg } },
  middle = { { colors.comment, colors.bg } },
  right = { { colors.comment, colors.bg } },
}

nightfox.tabline = {
  left = { { colors.comment, colors.bg_highlight }, { colors.comment, colors.bg } },
  middle = { { colors.fg_gutter, colors.bg_statusline } },
  right = { { colors.fg_gutter, colors.bg_statusline }, { colors.comment, colors.bg } },
  tabsel = { { colors.blue, colors.fg_gutter }, { colors.comment, colors.bg } },
}

return nightfox
