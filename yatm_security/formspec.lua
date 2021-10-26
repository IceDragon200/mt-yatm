local mod = yatm_security

local fspec = assert(foundation.com.formspec.api)
local Rect = assert(foundation.com.Rect)

function mod.render_button_bitmap(x, y, cols, rows, data, prefix, w, h)
  local texture_name
  local noclip = true
  local drawborder = false
  local byte
  local b
  local body = ""
  cols = cols or 8
  rows = rows or 8

  w = w or 1
  h = h or 1

  for row = 1,rows do
    byte = string.byte(data, row)

    for col = 1,cols do
      b = byte % 2
      byte = math.floor(byte / 2)

      if b == 0 then
        texture_name = "yatm_pattern_bits_empty.png"
      else
        texture_name = "yatm_pattern_bits_filled.png"
      end

      body =
        body ..
        fspec.image_button(x + (col - 1) * w, y + (row - 1) * h, w, h, texture_name, prefix .. "_" .. row .. "_" .. col, "", noclip, drawborder)
    end
  end

  return body, Rect.new(x, y, cols * w, rows * h)
end
