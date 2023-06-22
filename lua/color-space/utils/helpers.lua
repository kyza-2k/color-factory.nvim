local helpers = {}

local api, notify, fmt = vim.api, vim.notify, string.format

local err_warn = vim.schedule_wrap(
  function(group, attribute)
    notify(fmt('failed to get highlight %s for attribute %s\n%s', group, attribute, debug.traceback()), 'ERROR', {
      title = fmt('Highlight - get(%s)', group),
    })
  end
)

--- Get the value of a highlight group while handling errors and fallbacks.
--- If no attribute is specified, return the entire highlight table.
--- @param group string
--- @param attribute string?
--- @param fallback string?
--- @return string
helpers.get_hl = function(group, attribute, fallback)
  assert(group, 'cannot get a highlight without specifying a group name')
  local ns, opts = 0, { name = group, link = false }
  local hl = api.nvim_get_hl(ns, opts)
  hl.fg = hl.fg and ('#%06x'):format(hl.fg)
  hl.bg = hl.bg and ('#%06x'):format(hl.bg)

  if not attribute then return hl end

  local color = hl[attribute] or fallback
  if not color then
    if vim.v.vim_did_enter == 0 then
      api.nvim_create_autocmd(
        'User',
        { pattern = 'LazyDone', once = true, callback = function() err_warn(group, attribute) end }
      )
    else
      vim.schedule(function() err_warn(group, attribute) end)
    end
    return 'NONE'
  end
  return color
end

return helpers