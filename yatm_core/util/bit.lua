--
-- YATM bit module
--
-- In case the ffi bit is available, then this module acts as a wrapper around it
-- Otherwise it will try it's best to implement the module in plain lua.
--
yatm.bit = {}

local BITS = 32
local UINT32_MAX = 0xFFFFFFFF
local INT32_MAX = 0x7FFFFFFF
local INT32_MIN = -0x80000000

-- Lowercase Hex Table
local LHEX_TABLE = {
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
  [10] = "a",
  [11] = "b",
  [12] = "c",
  [13] = "d",
  [14] = "e",
  [15] = "f",
}

-- Uppercase Hex Table
local UHEX_TABLE = {
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

-- Only 32 bit operations to mirror the luajit one
-- Maps the bit position to the power of 2
local BIT_TABLE = {}

for i = 0,BITS do
  BIT_TABLE[i] = math.floor(math.pow(2, i))
end

local function to_unsigned(result)
  if result < 0 then
    return UINT32_MAX + result + 1
  else
    return result
  end
end

do
  local res = to_unsigned(-1)
  assert(res == 0xFFFFFFFF, "expected " .. res .. " to be equal to 0xFFFFFFFF")

  local res = to_unsigned(-2)
  assert(res == 0xFFFFFFFE, "expected " .. res .. " to be equal to 0xFFFFFFFE")
end

local function to_signed(value)
  if value > INT32_MAX then
    return value - UINT32_MAX - 1
  else
    return value
  end
end

do
  local res = to_signed(0xFFFFFFFF)
  assert(res == -1, "expected " .. res .. " to be equal to -1")
  local res = to_signed(0xFFFFFFFE)
  assert(res == -2, "expected " .. res .. " to be equal to -2")
end

local function to_unsigned_list(list)
  local result = {}
  for i, v in ipairs(list) do
    result[i] = to_unsigned(v)
  end
  return result
end

-- so you've chosen the hard way, good luck.
local function tohex(x, b)
  b = b or 8
  local ht = LHEX_TABLE
  if b < 0 then
    b = -b
    ht = UHEX_TABLE
  end
  local y = to_unsigned(x)
  local result = {}
  for i = 1,math.floor(b/2) do
    local byte = y % 256
    local lo = byte % 16
    local hi = math.floor(byte / 16)
    y = math.floor(y / 256)

    result[b - i * 2 + 1] = ht[hi]
    result[b - i * 2 + 2] = ht[lo]
  end
  return table.concat(result)
end

local function uarshift(x, n)
  error("I have no idea how to do this, sorry")
end

local function uband(...)
  local result = 0
  local v = to_unsigned_list({...})
  local j = #v

  for bit_index = 0,(BITS-1) do
    local base = v[1] % 2
    v[1] = math.floor(v[1] / 2)
    for i = 2,j do
      if base > 0 then
        local b = v[i] % 2
        if b == 0 then
          base = 0
        end
      end
      v[i] = math.floor(v[i] / 2)
    end
    if base > 0 then
      result = result + BIT_TABLE[bit_index]
    end
  end
  return result
end

local function ubnot(x)
  local result = 0
  local y = to_unsigned(x)
  for bit_index = 0,(BITS-1) do
    local base = y % 2
    y = math.floor(y / 2)
    if base == 0 then
      result = result + BIT_TABLE[bit_index]
    end
  end
  return result
end

local function ubor(...)
  local result = 0
  local v = to_unsigned_list({...})
  local j = #v

  for bit_index = 0,(BITS-1) do
    local base = v[1] % 2
    v[1] = math.floor(v[1] / 2)
    for i = 2,j do
      if base == 0 then
        local b = v[i] % 2
        if b > 0 then
          base = 1
        end
      end
      v[i] = math.floor(v[i] / 2)
    end
    if base > 0 then
      result = result + BIT_TABLE[bit_index]
    end
  end

  return result
end

local function ubxor(...)
  local result = 0
  local v = to_unsigned_list({...})
  local j = #v

  for bit_index = 0,(BITS-1) do
    local base = v[1] % 2
    v[1] = math.floor(v[1] / 2)
    for i = 2,j do
      local b = v[i] % 2
      if base ~= b then
        base = 1
      else
        base = 0
      end
      v[i] = math.floor(v[i] / 2)
    end
    if base > 0 then
      result = result + BIT_TABLE[bit_index]
    end
  end

  return result
end

local function ulshift(x, n)
  assert(n >= 0)
  local result = to_unsigned(x)
  for _ = 1,n do
    result = math.floor(result * 2)
  end
  return uband(result, 0xFFFFFFFF)
end

local function urshift(x, n)
  assert(n >= 0)
  local result = to_unsigned(x)
  for _ = 1,n do
    result = math.floor(result / 2)
  end
  return uband(result, 0xFFFFFFFF)
end

local function urol(x, n)
  assert(n >= 0)
  local y = to_unsigned(x)
  local result = 0
  for bit_index = 0,(BITS-1) do
    local b = y % 2
    if b > 0 then
      result = result + BIT_TABLE[(bit_index + n) % BITS]
    end
    y = math.floor(y / 2)
  end
  return result
end

local function uror(x, n)
  assert(n >= 0)
  local y = to_unsigned(x)
  local result = 0
  for bit_index = 0,(BITS-1) do
    local b = y % 2
    if b > 0 then
      result = result + BIT_TABLE[(bit_index - n) % BITS]
    end
    y = math.floor(y / 2)
  end
  return result
end

local function ubswap(x)
  local a, b, c, d
  local y = to_unsigned(x)
  a = y % 256
  y = math.floor(y / 256)
  b = y % 256
  y = math.floor(y / 256)
  c = y % 256
  y = math.floor(y / 256)
  d = y % 256

  return ulshift(a, 24) + ulshift(b, 16) + ulshift(c, 8) + d
end

local function arshift(x, n)
  return to_signed(uarshift(x, n))
end

local function band(...)
  return to_signed(uband(...))
end

local function bnot(x)
  return to_signed(ubnot(x))
end

local function bor(...)
  return to_signed(ubor(...))
end

local function bxor(...)
  return to_signed(ubxor(...))
end

local function lshift(x, n)
  return to_signed(ulshift(x, n))
end

local function rshift(x, n)
  return to_signed(urshift(x, n))
end

local function rol(x, n)
  return to_signed(urol(x, n))
end

local function ror(x, n)
  return to_signed(uror(x, n))
end

local function bswap(x)
  return to_signed(ubswap(x))
end

yatm.local_bit = {}

-- Store the local implementation in case we need it
yatm.local_bit.tohex = tohex
yatm.local_bit.arshift = arshift
yatm.local_bit.band = band
yatm.local_bit.bnot = bnot
yatm.local_bit.bor = bor
yatm.local_bit.bswap = bswap
yatm.local_bit.bxor = bxor
yatm.local_bit.lshift = lshift
yatm.local_bit.rol = rol
yatm.local_bit.ror = ror
yatm.local_bit.rshift = rshift

if yatm.native_bit then
  minetest.log("info", "using native bit module")
  -- native bit module is available, wrapper that mofo up
  yatm.bit.tohex = yatm.native_bit.tohex
  yatm.bit.arshift = yatm.native_bit.arshift
  yatm.bit.band = yatm.native_bit.band
  yatm.bit.bnot = yatm.native_bit.bnot
  yatm.bit.bor = yatm.native_bit.bor
  yatm.bit.bswap = yatm.native_bit.bswap
  yatm.bit.bxor = yatm.native_bit.bxor
  yatm.bit.lshift = yatm.native_bit.lshift
  yatm.bit.rol = yatm.native_bit.rol
  yatm.bit.ror = yatm.native_bit.ror
  yatm.bit.rshift = yatm.native_bit.rshift
else
  minetest.log("info", "using local bit module")
  yatm.bit.tohex = yatm.local_bit.tohex
  yatm.bit.arshift = yatm.local_bit.arshift
  yatm.bit.band = yatm.local_bit.band
  yatm.bit.bnot = yatm.local_bit.bnot
  yatm.bit.bor = yatm.local_bit.bor
  yatm.bit.bswap = yatm.local_bit.bswap
  yatm.bit.bxor = yatm.local_bit.bxor
  yatm.bit.lshift = yatm.local_bit.lshift
  yatm.bit.rol = yatm.local_bit.rol
  yatm.bit.ror = yatm.local_bit.ror
  yatm.bit.rshift = yatm.local_bit.rshift
end
