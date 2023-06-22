local M = {}

local utils = require('color_factory.utils')

M.convert = {}
local convert = M.convert

--- @param color string: The hex color to convert in the format "#RRGGBB".
--- @return number, number, number: The RGB values corresponding to the input color (range: 0-255).
function convert.hexToRGB(color)
  local hex = color:gsub('#', '')
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  return r or 0, g or 0, b or 0
end

--- @param r number: The red value of the color.
--- @param g number: The green value of the color.
--- @param b number: The blue value of the color.
--- @return string: The hex value of the color.
function convert.RGBToHex(r, g, b)
  local hex = string.format('#%02x%02x%02x', r, g, b)
  return hex
end

--- @param r number: The red value of the color.
--- @param g number: The green value of the color.
--- @param b number: The blue value of the color.
--- @return number, number, number: The HSL values of the color.
function convert.RGBToHSL(r, g, b)
  r, g, b = r / 255, g / 255, b / 255

  local maxVal = math.max(r, g, b)
  local minVal = math.min(r, g, b)
  local h, s, l

  l = (maxVal + minVal) / 2

  if maxVal == minVal then
    h = 0
    s = 0
  else
    local d = maxVal - minVal

    if l > 0.5 then
      s = d / (2 - maxVal - minVal)
    else
      s = d / (maxVal + minVal)
    end

    if maxVal == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif maxVal == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end

    h = h / 6
  end

  return h, s, l
end

--- @param h number: The hue value of the color.
--- @param s number: The saturation value of the color.
--- @param l number: The lightness value of the color.
--- @return number, number, number: The RGB values of the color.
function convert.HSLToRGB(h, s, l)
  local function hueToRGB(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
  end

  if s == 0 then
    local value = math.floor(l * 255 + 0.5)
    return value, value, value
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    local r = hueToRGB(p, q, h + 1 / 3)
    local g = hueToRGB(p, q, h)
    local b = hueToRGB(p, q, h - 1 / 3)
    return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
  end
end

M.transform = {}

-- Helper function to clamp a value between a minimum and maximum range.
local function clamp(value, min, max) return math.max(min, math.min(max, value)) end

--- @param color string: The hex color to lighten.
--- @param amount number: The amount to lighten the color.
--- @return string: The lightened color.
function M.transform.lighten(color, amount)
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
function M.transform.saturate(color, amount)
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
function M.transform.blend(color, hl, attr, amount)
  -- Get the attribute value from the highlight color.
  local hl2 = utils.get(hl, attr) -- hex format

  -- Convert the colors to RGB format.
  local color_rgb_r, color_rgb_g, color_rgb_b = convert.hexToRGB(color)
  local hl2_rgb_r, hl2_rgb_g, hl2_rgb_b = convert.hexToRGB(hl2)

  -- Calculate the blended color.
  local blended_color = {
    r = (1 - amount) * color_rgb_r + amount * hl2_rgb_r,
    g = (1 - amount) * color_rgb_g + amount * hl2_rgb_g,
    b = (1 - amount) * color_rgb_b + amount * hl2_rgb_b,
  }

  -- Convert the blended color back to hex format.
  local blended_color_hex = convert.RGBToHex(blended_color.r, blended_color.g, blended_color.b)

  return blended_color_hex
end

return M
