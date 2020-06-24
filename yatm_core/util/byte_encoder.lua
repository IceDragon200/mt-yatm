--
-- Little Endian - Byte Encoder
--
local bit = yatm.bit

local ByteEncoder = {}

-- Signed Integers
function ByteEncoder:e_iv(len, int)
  local r = int
  local i = 0
  local result = {}
  for j = 1,(len - 1) do
    i = j
    local byte = bit.band(r, 255)
    result[i] = byte
    r = bit.rshift(r, 8)
  end
  i = i + 1
  if int < 0 then
    -- set last bit to 1, meaning it's negative
    result[i] = bit.bor(bit.band(r, 127), 128)
  else
    result[i] = bit.band(r, 127)
  end
  return string.char(unpack(result))
end

function ByteEncoder:e_i64(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_iv(8, int)
end

function ByteEncoder:e_i32(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_iv(4, int)
end

function ByteEncoder:e_i24(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_iv(3, int)
end

function ByteEncoder:e_i16(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_iv(2, int)
end

function ByteEncoder:e_i8(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_iv(1, int)
end

-- Unsigned Integers
function ByteEncoder:e_uv(len, int)
  assert(int >= 0, "expected integer to be greater than or equal to 0")
  local r = int
  local result = {}
  for i = 1,len do
    local byte = bit.band(r, 255)
    result[i] = byte
    r = bit.rshift(r, 8)
  end
  return string.char(unpack(result))
end

function ByteEncoder:e_u64(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_uv(8, int)
end

function ByteEncoder:e_u32(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_uv(4, int)
end

function ByteEncoder:e_u24(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_uv(3, int)
end

function ByteEncoder:e_u16(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_uv(2, int)
end

function ByteEncoder:e_u8(int)
  assert(type(int) == "number", "expected an integer")
  return self:e_uv(1, int)
end

yatm_core.ByteEncoder = ByteEncoder
