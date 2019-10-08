local ByteBuf = assert(yatm_core.ByteBuf)
local Scalars = assert(yatm_core.binary_types.Scalars)
local Enum = yatm_core.Class:extends("Enum")
local ic = Enum.instance_class

function ic:initialize(data_type, mapping)
  self.m_name = "ENUM"
  self.m_data_type = data_type
  self.m_mapping = mapping
  self.m_inverse_mapping = {}
  for k,v in pairs(self.m_mapping) do
    self.m_inverse_mapping[v] = k
  end
end

function ic:size()
  return Scalars[self.m_data_type]:size()
end

function ic:write(stream, value)
  local data = self.m_mapping[value]
  if data then
    return Scalars[self.m_data_type]:write(stream, data)
  else
    error(self.m_name .. " unmapped value " .. value)
  end
end

function ic:read(stream)
  local v, bytes_read = Scalars[self.m_data_type]:read(stream)
  local result = self.m_inverse_mapping[v]
  if result then
    return result, bytes_read
  else
    error(self.m_name .. " unmapped inverse value " .. v)
  end
end

yatm_core.binary_types.Enum = Enum
