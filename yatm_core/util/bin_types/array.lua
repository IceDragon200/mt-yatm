local ByteBuf = assert(yatm_core.ByteBuf)
local ScalarTypes = yatm_core.binary_types.Scalars

local Array = yatm_core.Class:extends("Array")
local ic = Array.instance_class

function ic:initialize(value_type, len)
  ic._super.initialize(self)
  self.value_type = ScalarTypes.normalize_type(value_type)
  self.len = len
end

function ic:write(file, data)
  assert(data, "expected data")
  local all_bytes_written = 0
  local len = 0
  if self.len >= 0 then
    len = self.len
  else
    len = #data
    local bytes_written, err = ByteBuf.w_u32(file, self.len)
    all_bytes_written = all_bytes_written + bytes_written
    if err then
      return all_bytes_written, err
    end
  end
  for i = 1,len do
    local item = data[i]
    local bytes_written, err = self.value_type:write(file, item)
    all_bytes_written = all_bytes_written + bytes_written
    if err then
      return all_bytes_written, err
    end
  end
  return all_bytes_written, nil
end

function ic:read(file)
  local all_bytes_read = 0
  local len = 0
  if self.len >= 0 then
    len = self.len
  else
    local v, bytes_read = ByteBuf.r_u32(file)
    all_bytes_read = all_bytes_read + bytes_read
    len = v
  end
  local result = {}
  for i = 1,len do
    local item, bytes_read = self.value_type:read(file)
    all_bytes_read = all_bytes_read + bytes_read
    result[i] = item
  end
  return result, all_bytes_read
end

yatm_core.binary_types.Array = Array
