local convert = {}

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

return convert
