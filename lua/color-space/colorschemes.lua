local apply_highlights = require('color-space.apply_highlights')

local helpers = require('color-space.utils.helpers')

local colorschemes = {}

colorschemes.setup = function()
  local inherit_colors = {
    background = helpers.get_hl('Normal', 'bg', '#000000'),
    foreground = helpers.get_hl('Normal', 'fg', '#ffffff'),
  }

  colorschemes.colorscheme_colors = inherit_colors

  local augroup = vim.api.nvim_create_augroup('color-space.nvim', { clear = true })

  vim.api.nvim_create_autocmd({ 'ColorSchemePre' }, {
    callback = function() vim.api.nvim_cmd({ cmd = 'highlight', args = { 'clear' } }, {}) end,
    group = augroup,
  })

  vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
    callback = function()
      colorschemes.colorscheme_colors = inherit_colors
      colorschemes.setup()
    end,
    group = augroup,
  })
end

--- Prints the highlights of the current color scheme or the default color scheme
---
--- @param highlights table: A table containing highlights for different color schemes.
colorschemes.highlights = function(highlights)
  local colorscheme_name, fallback = vim.g.colors_name, '*'
  local colorscheme_highlights = highlights[colorscheme_name] or highlights[fallback]

  vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
    callback = function() colorschemes.highlights(highlights) end,
  })

  apply_highlights(colorscheme_highlights)
end

-- Returning the 'colorschemes' table
return colorschemes
