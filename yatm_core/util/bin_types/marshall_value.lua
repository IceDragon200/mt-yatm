local ByteBuf = assert(yatm_core.ByteBuf)

--[[
Marshall values can be a specific scalar type, annotated by a letter code

f for stringified floats
I for i32 integers
Q for u32 strings
B for u8 booleans
T for tables
]]
local MarshallValue = yatm_core.Class:extends("MarshallValue")
local ic = MarshallValue.instance_class

function ic:initialize()
  ic._super.initialize(self)
end

function ic:write_integer(file, data)
  -- integer, only integers are supported.
  local all_bytes_written = 0
  local bytes_written, err = ByteBuf.write(file, "I")
  all_bytes_written = all_bytes_written + bytes_written
  if err then
    return all_bytes_written, err
  end
  local bytes_written, err = ByteBuf.w_i32(file, data)
  all_bytes_written = all_bytes_written + bytes_written
  return all_bytes_written, err
end

function ic:write_float(file, data)
  -- integer, only integers are supported.
  local all_bytes_written = 0
  local bytes_written, err = ByteBuf.write(file, "f")
  all_bytes_written = all_bytes_written + bytes_written
  if err then
    return all_bytes_written, err
  end
  local bytes_written, err = ByteBuf.w_u8string(file, tostring(data))
  all_bytes_written = all_bytes_written + bytes_written
  return all_bytes_written, err
end

function ic:write_string(file, data)
  -- String
  local all_bytes_written = 0
  local bytes_written, err = ByteBuf.write(file, "Q")
  all_bytes_written = all_bytes_written + bytes_written
  if err then
    return all_bytes_written, err
  end
  local bytes_written, err = ByteBuf.w_u32string(file, data)
  all_bytes_written = all_bytes_written + bytes_written
  return all_bytes_written, err
end

function ic:write_boolean(file, data)
  local all_bytes_written = 0
  local bytes_written, err = ByteBuf.write(file, "B")
  all_bytes_written = all_bytes_written + bytes_written
  if err then
    return all_bytes_written, err
  end
  local bytes_written, err = ByteBuf.w_u8bool(file, data)
  all_bytes_written = all_bytes_written + bytes_written
  return all_bytes_written, err
end

function ic:write_table(file, data)
  local all_bytes_written = 0

  -- Write value identifier
  local bytes_written, err = ByteBuf.write(file, "T")
  all_bytes_written = all_bytes_written + bytes_written

  if err then
    return all_bytes_written, err
  end

  -- Determine table size
  local len = 0
  for _,_ in pairs(data) do
    len = len + 1
  end

  -- Write it's length
  local bytes_written, err = ByteBuf.w_i32(file, len)
  all_bytes_written = all_bytes_written + bytes_written

  if err then
    return all_bytes_written, err
  end

  for key,value in pairs(data) do
    local bytes_written, err = self:write(file, key)
    all_bytes_written = all_bytes_written + bytes_written

    if err then
      return all_bytes_written, err
    end

    local bytes_written, err = self:write(file, value)
    all_bytes_written = all_bytes_written + bytes_written

    if err then
      return all_bytes_written, err
    end
  end

  return all_bytes_written, nil
end

function ic:write(file, data)
  local all_bytes_written = 0
  if type(data) == "nil" then
    return ByteBuf.write(file, "0")
  elseif type(data) == "number" then
    if math.floor(data) == data then
      return self:write_integer(file, data)
    else
      return self:write_float(file, data)
    end
  elseif type(data) == "string" then
    return self:write_string(file, data)
  elseif type(data) == "boolean" then
    return self:write_boolean(file, data)
  elseif type(data) == "table" then
    return self:write_table(file, data)
  else
    error("unexpcted type " .. type(data))
  end
end

function ic:do_read_table(file)
  -- Read the number of key-value pairs present
  local result = {}
  local all_bytes_read = 0

  local num_pairs = ByteBuf.r_i32(file)

  for i = 1,num_pairs do
    local key, bytes_read = self:read(file)
    all_bytes_read = all_bytes_read + bytes_read

    local value, bytes_read = self:read(file)
    all_bytes_read = all_bytes_read + bytes_read

    result[key] = value
  end

  return result, all_bytes_read
end

function ic:read(file)
  local all_bytes_read = 0
  local type_code, bytes_read = ByteBuf.read(file, 1)
  all_bytes_read = all_bytes_read + bytes_read
  if type_code == "0" then
    return nil, all_bytes_read
  elseif type_code == "f" then
    local value, bytes_read = ByteBuf.r_u8string(file)
    return tonumber(value), all_bytes_read + bytes_read
  elseif type_code == "I" then
    local value, bytes_read = ByteBuf.r_i32(file)
    return value, all_bytes_read + bytes_read
  elseif type_code == "Q" then
    local value, bytes_read = ByteBuf.r_u32string(file)
    return value, all_bytes_read + bytes_read
  elseif type_code == "B" then
    local value, bytes_read = ByteBuf.r_u8bool(file)
    return value, all_bytes_read + bytes_read
  elseif type_code == "T" then
    local value, bytes_read = self:do_read_table(file)
    return value, all_bytes_read + bytes_read
  else
    error("unexpected type_code `" .. type_code .. "`")
  end
end

yatm_core.binary_types.MarshallValue = MarshallValue
