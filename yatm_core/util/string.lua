local HEX_TABLE = {
  [0] = "0",
  [1] = "1",
  [2] = "2",
  [3] = "3",
  [4] = "4",
  [5] = "5",
  [6] = "6",
  [7] = "7",
  [8] = "8",
  [9] = "9",
  [10] = "A",
  [11] = "B",
  [12] = "C",
  [13] = "D",
  [14] = "E",
  [15] = "F",
}

local HEX_TO_DEC = {}
for dec, hex in pairs(HEX_TABLE) do
  HEX_TO_DEC[hex] = dec
end
HEX_TO_DEC["a"] = 10
HEX_TO_DEC["b"] = 11
HEX_TO_DEC["c"] = 12
HEX_TO_DEC["d"] = 13
HEX_TO_DEC["e"] = 14
HEX_TO_DEC["f"] = 15

local HEXB_TO_DEC = {}
for hexc, dec in pairs(HEX_TO_DEC) do
  HEXB_TO_DEC[string.byte(hexc)] = dec
end

local HEX_BYTE_TO_DEC = {}
for hex_char, dec in pairs(HEX_TO_DEC) do
  HEX_BYTE_TO_DEC[string.byte(hex_char, 1, 1)] = dec
end

local function byte_to_hex(byte)
  local hinibble = math.floor(byte / 16)
  local lonibble = byte % 16
  return "\\x" .. HEX_TABLE[hinibble] .. HEX_TABLE[lonibble]
end

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

--
-- Removes any non-hex characters
--
function yatm_core.string_hex_clean(str)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1
  local i = 1
  local len = #bytes
  while i < len do
    local byte = bytes[i]
    if HEX_BYTE_TO_DEC[byte] then
      result[j] = string.char(byte)
      j = j + 1
    end
    i = i + 1
  end

  return table.concat(result)
end

function yatm_core.string_hex_decode(str)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1
  local i = 1
  local len = #bytes
  while i < len do
    local hinibble = bytes[i + 0] or 0
    local lonibble = bytes[i + 1] or 0
    local byte = HEX_BYTE_TO_DEC[hinibble] * 16 + HEX_BYTE_TO_DEC[lonibble]
    result[j] = string.char(byte)
    i = i + 2
    j = j + 1
  end

  return table.concat(result)
end

function yatm_core.string_hex_encode(str, spacer)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1
  local len = #bytes

  for i, byte in ipairs(bytes) do
    local hinibble = math.floor(byte / 16)
    local lonibble = byte % 16
    result[j] = HEX_TABLE[hinibble]
    result[j + 1] = HEX_TABLE[lonibble]
    j = j + 2
    if spacer then
      if i < len then
        result[j] = spacer
        j = j + #spacer
      end
    end
  end

  return table.concat(result)
end

function yatm_core.string_hex_escape(str, mode)
  mode = mode or "non-ascii"

  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  for i, byte in ipairs(bytes) do
    if mode == "non-ascii" then
      -- 92 /
      if byte >= 32 and byte < 127 and byte ~= 92 then
        result[i] = string.char(byte)
      else
        result[i] = byte_to_hex(byte)
      end
    else
      result[i] = byte_to_hex(byte)
    end
  end

  return table.concat(result)
end

local function handle_dec_escape(i, j, bytes, result)
  local d3 = bytes[i + 1] - 48
  local d2 = bytes[i + 2] - 48
  local d1 = bytes[i + 3] - 48
  result[j] = string.char(math.min(math.max(d3 * 100 + d2 * 10 + d1, 0), 255))
  i = i + 4

  return i, j
end

local function handle_hex_escape(i, j, bytes, result)
  local hinibble = bytes[i + 2]
  local lonibble = bytes[i + 3]
  if HEXB_TO_DEC[hinibble] and HEXB_TO_DEC[lonibble] then
    local hi = HEXB_TO_DEC[hinibble]
    local lo = HEXB_TO_DEC[lonibble]
    result[j] = string.char(hi * 16 + lo)
  else
    -- something isn't right, skip over this
    result[j] = string.char(byte)
    result[j + 1] = "x"
    result[j + 2] = string.char(hinibble)
    result[j + 3] = string.char(lonibble)
    j = j + 3
  end
  i = i + 4

  return i, j
end

--
--
-- @spec yatm_core.string_hex_unescape(String.t)
--   Resolves all hex encoded values in the string
--
-- Example:
--   "\\x00\x00\\x01\\x02" > "\x00\x00\x01\x02"
--   The above describes a literal string with the value \x00\x00\x01\x02
--   This function will unescape that sequence and produce the actual bytes 0 0 1 2
function yatm_core.string_hex_unescape(str)
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
        i, j = handle_hex_escape(i, j, bytes, result)
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
        i, j = handle_hex_escape(i, j, bytes, result)
      -- 48 0   57 9
      elseif bytes[i + 1] >= 48 and bytes[i + 1] <= 57 then
        -- decimal escaped
        i, j = handle_dec_escape(i, j, bytes, result)
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
