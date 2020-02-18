dofile(yatm_core.modpath .. "/util/string/bin_encoding.lua")
dofile(yatm_core.modpath .. "/util/string/dec_encoding.lua")
dofile(yatm_core.modpath .. "/util/string/hex_encoding.lua")
dofile(yatm_core.modpath .. "/util/string/oct_encoding.lua")

function yatm_core.string_unescape(str)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local i = 1
  local len = #bytes
  local j = 1

  while i <= len do
    local byte = bytes[i]

    -- 92 \
    if byte == 92 then
      -- 120 x
      if bytes[i + 1] == 120 then
        i, j = yatm_core.handle_escaped_hex(i, j, bytes, result)
      -- 48 0   57 9
      elseif bytes[i + 1] >= 48 and bytes[i + 1] <= 57 then
        -- decimal escaped
        i, j = yatm_core.handle_escaped_dec(i, j, bytes, result)
      -- 92 \
      elseif bytes[i + 1] == 92 then
        result[j] = "\\"
        i = i + 1
      -- other
      else
        result[j] = bytes[i + 1]
        i = i + 1
      end
    else
      result[j] = string.char(byte)
      i = i + 1
    end
    j = j + 1
  end
  return table.concat(result)
end

function yatm_core.string_sub_join(str, cols, joiner)
  local result = {}
  local remaining = str
  local i = 1
  while #remaining > 0 do
    local line = string.sub(remaining, 1, cols)
    remaining = string.sub(remaining, cols + 1)
    result[i] = line
    i = i + 1
  end
  return table.concat(result, joiner)
end

function yatm_core.string_remove_spaces(str)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local i = 1
  local len = #bytes
  local j = 1

  while i <= len do
    local byte = bytes[i]

    -- skip spaces, newlines, returns and tabs
    if byte == 32 or
       byte == 13 or
       byte == 10 or
       byte == 9 or
       byte == 0 then
      --
    else
      result[j] = string.char(byte)
      j = j + 1
    end
    i = i + 1
  end
  return table.concat(result)
end

function yatm_core.string_starts_with(str, expected)
  return expected == "" or string.sub(str, 1, #expected) == expected
end

function yatm_core.string_ends_with(str, expected)
  return expected == "" or string.sub(str, -#expected) == expected
end

function yatm_core.string_trim_leading(str, expected)
  if string.sub(str, 1, #expected) == expected then
    return string.sub(str, 1 + #expected, -1)
  else
    return str
  end
end

function yatm_core.string_trim_trailing(str, expected)
  if string.sub(str, -#expected) == expected then
    return string.sub(str, 1, -(1 + #expected) )
  else
    return str
  end
end

function yatm_core.string_pad_leading(str, count, padding)
  str = tostring(str)
  if padding == "" then
    error("argument error, expected padding to be a non-empty string")
  end
  local result = str
  while #result < count do
    result = padding .. result
  end
  return result
end

function yatm_core.string_pad_trailing(str, count, padding)
  str = tostring(str)
  if padding == "" then
    error("argument error, expected padding to be a non-empty string")
  end
  local result = str
  while #result < count do
    result = result .. padding
  end
  return result
end

function yatm_core.string_split(str, pattern)
  if str == "" then
    return {}
  end

  local result = {}

  if not pattern or pattern == "" then
    for i = 1,#str do
      result[i] = string.sub(str, i, i)
    end
  else
    local remaining = str
    local pattern_length = #pattern
    local i = 1

    while remaining do
      local head, tail = string.find(remaining, pattern)
      if head then
        local part = string.sub(remaining, 1, head - 1)
        result[i] = part
        remaining = string.sub(remaining, tail + 1)
      else
        result[i] = remaining
        remaining = nil
      end
      i = i + 1
    end
  end

  return result
end

function yatm_core.binary_splice(target, start, byte_count, bin)
  local head = string.sub(target, 1, start - 1)
  local tail = string.sub(target, start + byte_count)

  local mid
  if type(bin) == "number" then
    if byte_count == 1 then
      mid = string.char(bin)
    else
      error("using a number as the binary value and a non byte_count of 1 is not yet supported")
    end
  else
    -- expected to be a string
    mid = string.sub(bin, 1, byte_count)
  end

  return head .. mid .. tail
end
