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

local function byte_to_hex(byte)
  local hinibble = math.floor(byte / 16)
  local lonibble = byte % 16
  return "\\x" .. HEX_TABLE[hinibble] .. HEX_TABLE[lonibble]
end

function yatm_core.string_bin_encode(str)
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
  end

  return table.concat(result)
end

function yatm_core.string_dec_encode(str)
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
  end

  return table.concat(result)
end

function yatm_core.string_hex_encode(str)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1

  for i, byte in ipairs(bytes) do
    local hinibble = math.floor(byte / 16)
    local lonibble = byte % 16
    result[j] = HEX_TABLE[hinibble]
    result[j + 1] = HEX_TABLE[lonibble]
    j = j + 2
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
        local hinibble = bytes[i + 2]
        local lonibble = bytes[i + 3]
        if HEXB_TO_DEC[hinibble] and HEXB_TO_DEC[lonibble] then
          local hi = HEXB_TO_DEC[hinibble]
          local lo = HEXB_TO_DEC[lonibble]
          result[j] = string.char(hi * 16 + lo)
        else
          -- something isn't write, skip over this
          result[j] = string.char(byte)
          result[j + 1] = "x"
          result[j + 2] = string.char(hinibble)
          result[j + 3] = string.char(lonibble)
          j = j + 3
        end
        i = i + 4
      elseif bytes[i + 1] == 92 then
        result[j] = "\\"
        i = i + 1
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

-- https://stackoverflow.com/a/1647577
-- Modified for this
function yatm_core.string_split_iter(str, pat)
  pat = pat or '%s+'
  local st, g = 1, str:gmatch("()(" .. pat .. ")")

  local function getter(segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return str:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end

  return function()
    if st then
      return getter(st, g())
    end
  end
end

-- @spec split(String.t, String.t) :: {String.t}
function yatm_core.string_split(str, pattern)
  if not pattern or pattern == "" then
    local result = {}
    for i = 1,#str do
      result[i] = string.sub(str, i, i)
    end
    return result
  else
    local result = {}
    local iter = yatm_core.string_split_iter(str, pattern)
    local item = iter()
    local i = 0
    while item do
      i = i + 1
      result[i] = item
      item = iter()
    end
    return result
  end
end
