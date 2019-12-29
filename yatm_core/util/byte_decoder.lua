local bit = yatm.bit

if not bit then
  yatm.error("ByteDecoder module not available, because the bit module is not available")
  return
end

local ByteDecoder = {}

function ByteDecoder:d_iv(bytes, len)
  local result = 0

  for i = 1,(len - 1) do
    local byte = string.byte(bytes, i)
    byte = bit.lshift(byte, 8 * (i - 1))
    result = bit.bor(result, byte)
  end
  local byte = string.byte(bytes, len)
  if bit.band(byte, 128) == 128 then
    local bits = 8 * (len - 1)
    local high_byte = bit.lshift(byte, bits) - INT_MAX[len]
    result = bit.bor(high_byte, result)
    return result, len
  else
    result = bit.bor(result, bit.lshift(bit.band(byte, 127), 8 * (len - 1)))
    return result, len
  end
end

function ByteDecoder:d_i64(bytes)
  return self:d_iv(bytes, 8)
end

function ByteDecoder:d_i32(bytes)
  return self:d_iv(bytes, 4)
end

function ByteDecoder:d_i24(bytes)
  return self:d_iv(bytes, 3)
end

function ByteDecoder:d_i16(bytes)
  return self:d_iv(bytes, 2)
end

function ByteDecoder:d_i8(bytes)
  return self:d_iv(bytes, 1)
end

function ByteDecoder:d_uv(bytes, len)
  local result = 0

  for i = 1,len do
    local byte = string.byte(bytes, i)
    byte = bit.lshift(byte, 8 * (i - 1))
    result = bit.bor(byte, result)
  end
  return result, len
end

function ByteDecoder:d_u64(bytes)
  return self:d_uv(bytes, 8)
end

function ByteDecoder:d_u32(bytes)
  return self:d_uv(bytes, 4)
end

function ByteDecoder:d_u24(bytes)
  return self:d_uv(bytes, 3)
end

function ByteDecoder:d_u16(bytes)
  return self:d_uv(bytes, 2)
end

function ByteDecoder:d_u8(bytes)
  return self:d_uv(bytes, 1)
end

yatm_core.ByteDecoder = ByteDecoder