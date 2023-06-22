local helpers = require('color-space.utils.helpers') --- @module "color-space.utils.highlights"
local convert = require('color-space.utils.convert') --- @module "color-space.utils.highlights"

local transform = {}

-- Helper function to clamp a value between a minimum and maximum range.
local function clamp(value, min, max) return math.max(min, math.min(max, value)) end

--- @param color string: The hex color to lighten.
--- @param amount number: The amount to lighten the color.
--- @return string: The lightened color.
function transform.lighten(color, amount)
  local r, g, b = convert.hexToRGB(color)

  -- Apply the lightening effect by increasing the RGB values.
  r = clamp(r + (255 - r) * amount, 0, 255)
  g = clamp(g + (255 - g) * amount, 0, 255)
  b = clamp(b + (255 - b) * amount, 0, 255)

  local updated_color = convert.RGBToHex(r, g, b)
  return updated_color
end

--- @param color string The hex color to saturate in the format "#RRGGBB".
--- @param amount number The amount to saturate the color, a value between -1 and 1.
--- @return string: The saturated color in the format "#RRGGBB".
--- @raise Error if the input color is not a valid hex color or if the amount is not within the valid range.
function transform.saturate(color, amount)
  -- Convert the input color to RGB format.
  local r, g, b = convert.hexToRGB(color)

  -- Convert the RGB color to HSL format.
  local h, s, l = convert.RGBToHSL(r, g, b)

  -- Apply the saturation effect by modifying the saturation value.
  s = clamp(s + amount, 0, 1)

  -- Convert the modified HSL color back to RGB format.
  r, g, b = convert.HSLToRGB(h, s, l)

  -- Clamp the RGB values to the color range.
  r = clamp(r, 0, 255)
  g = clamp(g, 0, 255)
  b = clamp(b, 0, 255)

  -- Convert the modified RGB color back to hex format.
  local updated_color = convert.RGBToHex(r, g, b)

  return updated_color
end

--- @param color string: The base color to blend in the format "#RRGGBB".
--- @param hl string: The highlight color to blend in the format "#RRGGBB".
--- @param attr string: The attribute of the highlight color to blend (e.g., "r", "g", "b").
--- @param amount number: The amount to blend the colors, a value between 0 and 1.
--- @return string: The blended color in the format "#RRGGBB".
function transform.blend(color, hl, attr, amount)
  -- Get the attribute value from the highlight color.
  local hl2 = helpers.get_hl(hl, attr) -- hex format

  -- Convert the colors to RGB format.
  local color_r, color_g, color_b = convert.hexToRGB(color)
  local hl_r, hl_g, hl_b = convert.hexToRGB(hl2)

  -- Calculate the blended color.
  local blended_color = {
    r = (1 - amount) * color_r + amount * hl_r,
    g = (1 - amount) * color_g + amount * hl_g,
    b = (1 - amount) * color_b + amount * hl_b,
  }

  -- Convert the blended color back to hex format.
  local blended_color_hex = convert.RGBToHex(blended_color.r, blended_color.g, blended_color.b)

  return blended_color_hex
end

return transform
