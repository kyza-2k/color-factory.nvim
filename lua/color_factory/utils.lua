local M = {}

local attrs = {
  fg = true,
  bg = true,
  sp = true,
  blend = true,
  bold = true,
  italic = true,
  standout = true,
  underline = true,
  undercurl = true,
  underdouble = true,
  underdotted = true,
  underdashed = true,
  strikethrough = true,
  reverse = true,
  nocombine = true,
  link = true,
  default = true,
}

-- Credit to: github.com/akinsho
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/highlights.lua

local api, notify, fmt, augroup = vim.api, vim.notify, string.format, vim.api.nvim_create_augroup

local err_warn = vim.schedule_wrap(function(group, attribute)
  notify(fmt('failed to get highlight %s for attribute %s\n%s', group, attribute, debug.traceback()), 'ERROR', {
    title = fmt('Highlight - get(%s)', group),
  }) -- stylua: ignore
end)

---@private
---@param opts {name: string?, link: boolean?}?
---@param ns integer?
---@return HLData
local function get_hl_as_hex(opts, ns)
  ns, opts = ns or 0, opts or {}
  opts.link = opts.link ~= nil and opts.link or false
  local hl = api.nvim_get_hl(ns, opts)
  hl.fg = hl.fg and ('#%06x'):format(hl.fg)
  hl.bg = hl.bg and ('#%06x'):format(hl.bg)
  return hl
end

---Get the value a highlight group whilst handling errors, fallbacks as well as returning a gui value
---If no attribute is specified return the entire highlight table
---in the right format
---@param group string
---@param attribute string?
---@param fallback string?
---@return string
---@overload fun(group: string): HLData
M.get = function(group, attribute, fallback)
  assert(group, 'cannot get a highlight without specifying a group name')
  local data = get_hl_as_hex({ name = group })
  if not attribute then return data end

  assert(attrs[attribute], ('the attribute passed in is invalid: %s'):format(attribute))
  local color = data[attribute] or fallback
  if not color then
    if vim.v.vim_did_enter == 0 then
      api.nvim_create_autocmd('User', {
        pattern = 'LazyDone',
        once = true,
        callback = function() err_warn(group, attribute) end,
      })
    else
      vim.schedule(function() err_warn(group, attribute) end)
    end
    return 'NONE'
  end
  return color
end

return M
