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

local function byte_to_escaped_hex(byte)
  local hinibble = math.floor(byte / 16)
  local lonibble = byte % 16
  return "\\x" .. HEX_TABLE[hinibble] .. HEX_TABLE[lonibble]
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

--
--
-- @spec string_hex_pair_to_byte(String) :: Integer
-- @doc Decode a hexpair string as a plain byte
-- @example string_hex_pair_to_byte("FF") -- => 255
function yatm_core.string_hex_pair_to_byte(pair)
  local hinibble = string.byte(pair, 1) or 0
  local lonibble = string.byte(pair, 2) or 0
  return HEX_BYTE_TO_DEC[hinibble] * 16 + HEX_BYTE_TO_DEC[lonibble]
end

function yatm_core.lua_string_hex_decode(str)
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

function yatm_core.lua_string_hex_encode(str, spacer)
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

function yatm_core.lua_string_hex_escape(str, mode)
  mode = mode or "non-ascii"

  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  for i, byte in ipairs(bytes) do
    if mode == "non-ascii" then
      -- 92 \
      if byte == 92 then
        result[i] = "\\\\"
      elseif byte >= 32 and byte < 127  then
        result[i] = string.char(byte)
      else
        result[i] = byte_to_escaped_hex(byte)
      end
    else
      result[i] = byte_to_escaped_hex(byte)
    end
  end

  return table.concat(result)
end

function yatm_core.handle_escaped_hex(i, j, bytes, result)
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
function yatm_core.lua_string_hex_unescape(str)
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

if yatm.native_utils then
  local native_utils = yatm.native_utils
  local ffi = yatm.ffi
  local spacer_buffer = ffi.new("char[4096]")

  function yatm_core.ffi_string_hex_decode(str)
    return yatm_core.ffi_encoder(str, function (pcursor, pstr, pbuffer)
      native_utils.yatm_core_string_hex_decode(pcursor, pstr, pbuffer)
    end)
  end

  function yatm_core.ffi_string_hex_encode(str, spacer)
    spacer = spacer or ""
    local spacer_len = #spacer
    ffi.copy(spacer_buffer, spacer, spacer_len)
    return yatm_core.ffi_encoder(str, function (pcursor, pstr, pbuffer)
      native_utils.yatm_core_string_hex_encode(pcursor, pstr, pbuffer, spacer_len, spacer_buffer)
    end)
  end

  function yatm_core.ffi_string_hex_escape(str, mode)
    mode = mode or "non-ascii"
    local mode_int = 0

    if mode ~= "non-ascii" then
      mode_int = 1
    end

    return yatm_core.ffi_encoder(str, function (pcursor, pstr, pbuffer)
      native_utils.yatm_core_string_hex_escape(pcursor, pstr, pbuffer, mode_int)
    end)
  end

  function yatm_core.ffi_string_hex_unescape(str)
    return yatm_core.ffi_encoder(str, function (pcursor, pstr, pbuffer)
      native_utils.yatm_core_string_hex_unescape(pcursor, pstr, pbuffer)
    end)
  end

  minetest.log("info", "using FFI string_hex functions")
  yatm_core.string_hex_decode = yatm_core.ffi_string_hex_decode
  yatm_core.string_hex_encode = yatm_core.ffi_string_hex_encode
  yatm_core.string_hex_escape = yatm_core.ffi_string_hex_escape
  yatm_core.string_hex_unescape = yatm_core.ffi_string_hex_unescape
else
  minetest.log("info", "using lua string_hex functions")
  yatm_core.string_hex_decode = yatm_core.lua_string_hex_decode
  yatm_core.string_hex_encode = yatm_core.lua_string_hex_encode
  yatm_core.string_hex_escape = yatm_core.lua_string_hex_escape
  yatm_core.string_hex_unescape = yatm_core.lua_string_hex_unescape
end
