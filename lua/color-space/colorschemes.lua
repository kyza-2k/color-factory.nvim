local colorschemes = {}

local apply_highlights = require('color-space.apply_highlights')
local helpers = require('color-space.utils.helpers')

colorschemes.setup = function()
  local default_highlights = require('color-space.highlights.defaults')

  local inherit_colors = {
    background = helpers.get_hl('Normal', 'bg', '#111111'),
    foreground = helpers.get_hl('Normal', 'fg', '#ffffff'),
  }

  -- Assign the colors at the time of setup
  colorschemes.colorscheme_colors = inherit_colors

  local augroup = vim.api.nvim_create_augroup('color-space.nvim', { clear = true })

  -- Clears highlights on ColorSchemePre event
  vim.api.nvim_create_autocmd({ 'ColorSchemePre' }, {
    callback = function() vim.api.nvim_cmd({ cmd = 'highlight', args = { 'clear' } }, {}) end,
    group = augroup,
  })

  -- Updates colorscheme on ColorScheme event
  vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
    callback = function()
      colorschemes.colorscheme_colors = inherit_colors
      colorschemes.setup()
    end,
    group = augroup,
  })

  apply_highlights(default_highlights())
end

return colorschemes
