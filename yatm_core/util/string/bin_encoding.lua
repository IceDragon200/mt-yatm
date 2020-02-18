function yatm_core.string_bin_encode(str, spacer)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1

  for i, byte in ipairs(bytes) do
    local b0 = byte % 2
    local b1 = math.floor(byte / 2) % 2
    local b2 = math.floor(byte / 4) % 2
    local b3 = math.floor(byte / 8) % 2
    local b4 = math.floor(byte / 16) % 2
    local b5 = math.floor(byte / 32) % 2
    local b6 = math.floor(byte / 64) % 2
    local b7 = math.floor(byte / 128) % 2

    result[j] = b7
    result[j + 1] = b6
    result[j + 2] = b5
    result[j + 3] = b4
    result[j + 4] = b3
    result[j + 5] = b2
    result[j + 6] = b1
    result[j + 7] = b0
    j = j + 8
    if spacer then
      if i < len then
        result[j] = spacer
        j = j + #spacer
      end
    end
  end

  return table.concat(result)
end
