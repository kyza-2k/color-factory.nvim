local colorspace = require('color-space')

local function get_current_colors()
  local colors = colorspace.colors

  return {
    Normal = { bg = colors['background']:hex(), fg = colors['foreground']:l(0.1):hex() },
    StatusLine = { bg = colors['background']:l(-0.1):hex(), fg = colors['foreground']:l(0.1):hex() },
  }
end

return get_current_colors
