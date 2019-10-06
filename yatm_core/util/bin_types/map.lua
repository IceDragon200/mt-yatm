local ByteBuf = require("app/util/byte_buf")
local ScalarTypes = require("app/util/bin_types/scalars")
local Map = require("app/util/map")

local MapType = LilyObject:extends("MapType")
local ic = MapType.instance_class

function ic:initialize(key_type, value_type)
  ic._super.initialize(self)
  self.key_type = ScalarTypes.normalize_type(key_type)
  self.value_type = ScalarTypes.normalize_type(value_type)
  assert(self.key_type, "expected key type to be set")
  assert(self.value_type, "expected value type to be set")
end

function ic:write(file, data)
  local len = Map.length(data)
  local all_bytes_written = 0
  local bytes_written, err = ByteBuf.w_u32(file, len)
  all_bytes_written = all_bytes_written + bytes_written
  if err then
    return all_bytes_written, err
  end
  for key,value in pairs(data) do
    local bytes_written, err = self.key_type:write(file, key)
    all_bytes_written = all_bytes_written + bytes_written
    if err then
      return all_bytes_written, err
    end
    local bytes_written, err = self.value_type:write(file, value)
    all_bytes_written = all_bytes_written + bytes_written
    if err then
      return all_bytes_written, err
    end
  end
  return all_bytes_written, nil
end

function ic:read(file)
  local len, all_bytes_read = ByteBuf.r_u32(file)
  if len then
    local result = {}
    for _ = 1,len do
      local key, bytes_read = self.key_type:read(file)
      all_bytes_read = all_bytes_read + bytes_read
      local value, bytes_read = self.value_type:read(file)
      all_bytes_read = all_bytes_read + bytes_read
      result[key] = value
    end
    return result, all_bytes_read
  else
    return nil, all_bytes_read
  end
end

return MapType
