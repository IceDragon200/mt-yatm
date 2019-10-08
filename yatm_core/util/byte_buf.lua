local bit = yatm.bit
local ByteBuf = {}

--
-- Writer functions
--
function ByteBuf.write(file, data)
  local t = type(data)
  local num_bytes = 0
  -- Arrays, not maps
  if t == "table" then
    for _, chunk in ipairs(data) do
      local bytes_written, err = ByteBuf.write(file, chunk)
      num_bytes = num_bytes + bytes_written
      if err then
        return num_bytes, err
      end
    end
  -- Strings woot!
  elseif t == "string" then
    local success, err = file:write(data)
    if success then
      num_bytes = num_bytes + #data
    else
      return num_bytes, err
    end
  -- Bytes, woot!
  elseif t == "number" then
    if data > 255 then
      return num_bytes, "byte overflow"
    elseif data < -128 then
      return num_bytes, "byte overflow"
    end
    local success, err = file:write(string.char(data))
    if success then
      num_bytes = num_bytes + 1
    else
      return num_bytes, err
    end
  else
    return num_bytes, "unexpected type " .. t
  end
  return num_bytes, nil
end

-- Signed Integers
function ByteBuf.w_iv(file, len, int)
  local r = int
  local num_bytes = 0
  for _ = 1,(len - 1) do
    local byte = bit.band(r, 255)
    local written, err = ByteBuf.write(file, byte)
    if err then
      return num_bytes, err
    end
    r = bit.rshift(r, 8)
    num_bytes = num_bytes + written
  end
  if int < 0 then
    -- set last bit to 1, meaning it's negative
    local written, err = ByteBuf.write(file, bit.bor(bit.band(r, 127), 128))
    if err then
      return num_bytes, err
    end
    num_bytes = num_bytes + written
  else
    local written, err = ByteBuf.write(file, bit.band(r, 127))
    if err then
      return num_bytes, err
    end
    num_bytes = num_bytes + written
  end
  return num_bytes
end

function ByteBuf.w_i64(file, int)
  return ByteBuf.w_iv(file, 8, int)
end

function ByteBuf.w_i32(file, int)
  return ByteBuf.w_iv(file, 4, int)
end

function ByteBuf.w_i24(file, int)
  return ByteBuf.w_iv(file, 3, int)
end

function ByteBuf.w_i16(file, int)
  return ByteBuf.w_iv(file, 2, int)
end

function ByteBuf.w_i8(file, int)
  return ByteBuf.w_iv(file, 1, int)
end

-- Unsigned Integers
function ByteBuf.w_uv(file, len, int)
  assert(int >= 0, "expected integer to be greater than or equal to 0")
  local r = int
  local num_bytes = 0
  for _ = 1,len do
    local byte = bit.band(r, 255)
    local written, err = ByteBuf.write(file, byte)
    if err then
      return num_bytes, err
    end
    r = bit.rshift(r, 8)
    num_bytes = num_bytes + written
  end
  return num_bytes
end

function ByteBuf.w_u64(file, int)
  return ByteBuf.w_uv(file, 8, int)
end

function ByteBuf.w_u32(file, int)
  return ByteBuf.w_uv(file, 4, int)
end

function ByteBuf.w_u24(file, int)
  return ByteBuf.w_uv(file, 3, int)
end

function ByteBuf.w_u16(file, int)
  return ByteBuf.w_uv(file, 2, int)
end

function ByteBuf.w_u8(file, int)
  return ByteBuf.w_uv(file, 1, int)
end

-- Floating Point Values - IEEE754
-- http://eng.umb.edu/~cuckov/classes/engin341/Reference/IEEE754.pdf
-- http://sandbox.mc.edu/~bennet/cs110/flt/ftod.html
-- http://sandbox.mc.edu/~bennet/cs110/flt/dtof.html
-- TODO: still a work in progress
function ByteBuf.w_fv(file, exponent_bits, mantissa_bits, flt)
  local sign = 0
  if flt < 0 then
    sign = 1
  end

  local int = math.floor(flt)
  local flt = flt - int

  local mantissa_fract = 0

  local m = flt
  for i = 0,mantissa_bits do
    m = m * 2
    if m >= 1 then
      m = m - 1
      mantissa_fract = bit.bor(mantissa_fract, bit.lshift(1, i))
    end
  end

  local e = int
  local exponent = 1
  while e > 1 do
    e = bit.rshift(e, 1)
    exponent = exponent + 1
  end
end

function ByteBuf.w_f16(file, flt)
  ByteBuf.w_fv(file, 5, 10, flt)
end

function ByteBuf.w_f24(file, flt)
  ByteBuf.w_fv(file, 5, 10, flt)
end

function ByteBuf.w_f32(file, flt)
  ByteBuf.w_fv(file, 8, 23, flt)
end

function ByteBuf.w_f64(file, flt)
  ByteBuf.w_fv(file, 11, 52, flt)
end

--function ByteBuf.w_f128(file, flt)
--  ByteBuf.w_fv(file, 15, 112, flt)
--end
--
--function ByteBuf.w_f256(file, flt)
--  ByteBuf.w_fv(file, 19, 237, flt)
--end

-- Helpers
function ByteBuf.w_u8bool(file, bool)
  if bool then
    return ByteBuf.w_u8(file, 1)
  else
    return ByteBuf.w_u8(file, 0)
  end
end

-- Null-Terminated string
function ByteBuf.w_cstring(file, str)
  local num_bytes, err = ByteBuf.write(file, str)
  if err then
    return num_bytes, err
  end
  local nbytes, err = ByteBuf.w_u8(file, 0)
  return num_bytes + nbytes, err
end

function ByteBuf.w_u8string(file, data)
  -- length
  local len = #data
  if len > 255 then
    error("string is too long")
  end
  local num_bytes, err  = ByteBuf.w_u8(file, len)
  if err then
    return num_bytes, err
  end
  local written, err = ByteBuf.write(file, data)
  return num_bytes + written, err
end

function ByteBuf.w_u16string(file, data)
  -- length
  local len = #data
  if len > 65535 then
    error("string is too long")
  end
  local num_bytes = ByteBuf.w_u16(file, len)
  if err then
    return num_bytes, err
  end
  local written, err = ByteBuf.write(file, data)
  return num_bytes + written, err
end

function ByteBuf.w_u32string(file, data)
  -- length
  local len = #data
  if len > 4294967295 then
    error("string is too long")
  end
  local num_bytes = ByteBuf.w_u32(file, len)
  if err then
    return num_bytes, err
  end
  local written, err = ByteBuf.write(file, data)
  return num_bytes + written, err
end

function ByteBuf.w_u64string(file, data)
  -- length
  local len = #data
  if len > 4294967295 then
    error("string is too long")
  end
  local num_bytes = ByteBuf.w_u32(file, len)
  if err then
    return num_bytes, err
  end
  local written, err = ByteBuf.write(file, data)
  return num_bytes + written, err
end

function ByteBuf.w_map(file, key_type, value_type, data)
  -- length
  local len = yatm_core.table_length(data)
  -- number of items in the map
  local num_bytes = ByteBuf.w_u32(file, len)
  local writer_name = "w_" .. value_type
  local key_writer_name = "w_" .. key_type
  for key, item in pairs(data) do
    local written, err = ByteBuf[key_writer_name](file, key)
    num_bytes = num_bytes + written
    if err then
      return num_bytes, err
    end
    local written, err = ByteBuf[writer_name](file, item)
    num_bytes = num_bytes + written
    if err then
      return num_bytes, err
    end
  end
  return num_bytes, nil
end

function ByteBuf.w_varray(file, type, data, len)
  local writer_name = "w_" .. type
  local all_bytes_written = 0
  for i = 1,len do
    local item = data[i]
    local bytes_written, err = ByteBuf[writer_name](file, item)
    all_bytes_written = all_bytes_written + bytes_written
    if err then
      return all_bytes_written, err
    end
  end
  return all_bytes_written, nil
end

function ByteBuf.w_array(file, type, data)
  -- length
  local len = #data
  -- number of items in the array
  local all_bytes_written = ByteBuf.w_u32(file, len)
  local bytes_written, err = ByteBuf.w_varray(file, type, data, len)
  return all_bytes_written + bytes_written, err
end

--
-- Reader
--
function ByteBuf.read(file, len)
  return file:read(len)
end

local INT_MAX = {
  [1] = math.floor(math.pow(2, 8)),
  [2] = math.floor(math.pow(2, 16)),
  [3] = math.floor(math.pow(2, 24)),
  [4] = math.floor(math.pow(2, 32)),
  [8] = math.floor(math.pow(2, 64)),
}

function ByteBuf.r_iv(file, len)
  local result = 0
  local bytes, read_len = ByteBuf.read(file, len)
  if read_len < len then
    return nil, read_len, "read underflow"
  end
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

function ByteBuf.r_i64(file)
  return ByteBuf.r_iv(file, 8)
end

function ByteBuf.r_i32(file)
  return ByteBuf.r_iv(file, 4)
end

function ByteBuf.r_i24(file)
  return ByteBuf.r_iv(file, 3)
end

function ByteBuf.r_i16(file)
  return ByteBuf.r_iv(file, 2)
end

function ByteBuf.r_i8(file)
  return ByteBuf.r_iv(file, 1)
end

function ByteBuf.r_uv(file, len)
  local result = 0
  local bytes, read_len = ByteBuf.read(file, len)
  if read_len < len then
    return nil, read_len, "read underflow"
  end
  for i = 1,len do
    local byte = string.byte(bytes, i)
    byte = bit.lshift(byte, 8 * (i - 1))
    result = bit.bor(byte, result)
  end
  return result, len
end

function ByteBuf.r_u64(file)
  return ByteBuf.r_uv(file, 8)
end

function ByteBuf.r_u32(file)
  return ByteBuf.r_uv(file, 4)
end

function ByteBuf.r_u24(file)
  return ByteBuf.r_uv(file, 3)
end

function ByteBuf.r_u16(file)
  return ByteBuf.r_uv(file, 2)
end

function ByteBuf.r_u8(file)
  return ByteBuf.r_uv(file, 1)
end

function ByteBuf.r_u8bool(file, bool)
  local result, bytes_read = ByteBuf.r_u8(file)
  if bytes_read > 0 then
    return result ~= 0, bytes_read
  else
    return nil, bytes_read
  end
end

function ByteBuf.r_cstring(file)
  local bytes_read = 0
  local result = ''
  while true do
    local c = ByteBuf.read(file, 1)
    bytes_read = bytes_read + 1
    if c == '\0' then
      result = result .. '\0'
      break
    elseif c == '' then
      error("unexpected termination")
    else
      result = result .. c
    end
  end
  return result, bytes_read
end

function ByteBuf.r_u8string(file)
  local len, all_bytes_read = ByteBuf.r_u8(file)
  if all_bytes_read > 0 then
    local str, bytes_read = ByteBuf.read(file, len)
    return str, all_bytes_read + bytes_read
  else
    return nil, all_bytes_read
  end
end

function ByteBuf.r_u16string(file)
  local len, all_bytes_read = ByteBuf.r_u16(file)
  if all_bytes_read > 0 then
    local str, bytes_read = ByteBuf.read(file, len)
    return str, all_bytes_read + bytes_read
  else
    return nil, all_bytes_read
  end
end

function ByteBuf.r_u24string(file)
  local len, all_bytes_read = ByteBuf.r_u24(file)
  if all_bytes_read > 0 then
    local str, bytes_read = ByteBuf.read(file, len)
    return str, all_bytes_read + bytes_read
  else
    return nil, all_bytes_read
  end
end

function ByteBuf.r_u32string(file)
  local len, all_bytes_read = ByteBuf.r_u32(file)
  if all_bytes_read > 0 then
    local str, bytes_read = ByteBuf.read(file, len)
    return str, all_bytes_read + bytes_read
  else
    return nil, all_bytes_read
  end
end

function ByteBuf.r_map(file, key_type, value_type)
  local reader_key = "r_" .. key_type
  local reader_value_key = "r_" .. value_type
  local element_count, all_bytes_read = ByteBuf.r_u32(file)
  local result = {}
  if element_count then
    local reader = ByteBuf[reader_key]
    for _ = 1,element_count do
      local key, bytes_read = reader(file)
      all_bytes_read = all_bytes_read + bytes_read
      local value, bytes_read = ByteBuf[reader_value_key](file)
      all_bytes_read = all_bytes_read + bytes_read
      result[key] = value
    end
    return result, all_bytes_read
  else
    return nil, all_bytes_read
  end
end

function ByteBuf.r_varray(file, value_type, len)
  local result = {}
  local reader_key = "r_" .. value_type
  local reader = ByteBuf[reader_key]
  local all_bytes_read = 0
  for i = 1,len do
    local value, bytes_read = reader(file)
    all_bytes_read = all_bytes_read + bytes_read
    result[i] = value
  end
  return result, all_bytes_read
end

function ByteBuf.r_array(file, value_type)
  local len, all_bytes_read = ByteBuf.r_u32(file)
  if len then
    local value, bytes_read = ByteBuf.r_varray(file, value_type, len)
    return value, all_bytes_read + bytes_read
  else
    return nil, all_bytes_read
  end
end

yatm_core.ByteBuf = ByteBuf
