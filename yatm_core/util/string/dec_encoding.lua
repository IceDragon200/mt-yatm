function yatm_core.string_dec_encode(str, spacer)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1

  for i, byte in ipairs(bytes) do
    local h = math.floor(byte / 100) % 10
    local t = math.floor(byte / 10) % 10
    local o = byte % 10

    result[j] = h
    result[j + 1] = t
    result[j + 2] = o

    j = j + 3
    if spacer then
      if i < len then
        result[j] = spacer
        j = j + #spacer
      end
    end
  end

  return table.concat(result)
end

function yatm_core.handle_escaped_dec(i, j, bytes, result)
  local d3 = bytes[i + 1] - 48
  local d2 = bytes[i + 2] - 48
  local d1 = bytes[i + 3] - 48
  result[j] = string.char(math.min(math.max(d3 * 100 + d2 * 10 + d1, 0), 255))
  i = i + 4

  return i, j
end
