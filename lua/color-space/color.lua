local convert = require('color-space.utils.convert')
local transform = require('color-space.utils.transform')

-- stylua: ignore

--- Table defining the aliases for color modifications.
--- Each pair of values represents the primary key and its corresponding alias.
--- @type table
local color_aliases = {
  "h", "hue",
  "s", "saturation",
  "l", "lightness",
  "b", "blend",
}

--- Table defining the base colors.
--- @type table
local colors = {
  purple = '#4f4f93',
}

--- A mapping table of color modification keys to their corresponding utility functions
local modification_functions = {
  s = transform.saturate,
  l = transform.lighten,
  b = transform.blend,
}

--- Applies color modifications to a color
--- @param color string: The base color.
--- @param modifications table: A table of modifications to apply to the color.
--- @return string: The modified color.
local function modify(color, modifications)
  for _, modification in ipairs(modifications) do
    local key, value = modification[1], modification[2]
    local modifier = modification_functions[key]

    if modifier then
      local hl, amount = modification[3], modification[4]
      local modified_color = key == 'b' and modifier(color, value, hl, amount) or modifier(color, value)
      color = modified_color
    end
  end

  return color
end

--- Creates a color instance with the given name.
--- @param name function: The name of the color.
--- @return table: The color instance.
local function color(name)
  local color_instance = { name = name, modifications = {} }

  local color_metatable = {
    __index = color_instance,

    --- Returns the hexadecimal representation of the color instance.
    --- @return string: The hexadecimal color value.
    __tostring = function(self) return self:hex() end,
  }

  --- Returns the hexadecimal representation of the color instance.
  --- @return string: The hexadecimal color value.
  function color_instance:hex()
    local modified_color = modify(colors[self.name], self.modifications)
    return modified_color
  end

  --- Returns the RGB representation of the color instance.
  --- @return number, number, number: The red, green, and blue values respectively.
  function color_instance:rgb()
    local modified_color = modify(colors[self.name], self.modifications)
    return convert.hexToRGB(modified_color)
  end

  for i = 1, #color_aliases, 2 do
    local key, alias_key = color_aliases[i], color_aliases[i + 1]

    --- Modifies the color instance with the specified value for the given key.
    --- @param value any: The value to set for the key.
    --- @return table: The modified color instance.
    color_instance[key] = function(self, value, ...)
      table.insert(self.modifications, { key, value, unpack({ ... }) })
      return self
    end

    color_instance[alias_key] = color_instance[key]
  end

  return setmetatable(color_instance, color_metatable)
end

return setmetatable({}, {
  __index = function(_, key) return color(key) end,
})
