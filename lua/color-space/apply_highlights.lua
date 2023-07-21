return function(highlights)
  -- stylua: ignore

  local keys = {
    "fg", "bg", "sp", "blend", "bold", "standout",
    "underline", "undercurl", "underdouble", "underdotted",
    "strikethrough", "italic", "nocombine",
    "cterm", "ctermfg", "ctermbg", "default", "link",
  }

  for group, gui in pairs(highlights) do
    local attrs = {}

    for _, key in ipairs(keys) do
      attrs[key] = gui[key]
    end

    if gui.clear then vim.api.nvim_cmd({ cmd = 'highlight', args = { 'clear', group } }, {}) end

    local success, error = pcall(function() vim.api.nvim_set_hl(0, group, attrs) end)

    if not success then
      print("color-space.nvim: Error setting highlight group '" .. group .. "': " .. error)
      return
    end
  end
end
