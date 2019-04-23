--[[
OKU's memory model using a single string.
]]

local StringMemory = {
  mt = {},
}

function StringMemory.new(size)
  local memory = {}
  setmetatable(memory, { __index = StringMemory.mt })
  memory:initialize(size)
  return memory
end

function StringMemory.mt:initialize(size)
  self.size = size
  self.data = string.rep('\0', size)
end

function StringMemory.mt:bytes(index, len)
  local len = len or 1
  if len > 0 then
    local end_index = index + len - 1
    return {string.byte(self.data, index + 1, end_index + 1)}
  else
    return {}
  end
end

function StringMemory.mt:put_bytes(index, bytes)
  if type(bytes) == "string" then
    --
  elseif type(bytes) == "number" then
    bytes = string.char(bytes)
  elseif type(bytes) == "table" then
    bytes = string.char(unpack(bytes))
  end
  local index = index + 1
  local end_index = index + #bytes - 1
  self.data =
    string.sub(self.data, 1, index - 1) ..
    bytes ..
    string.sub(self.data, end_index, #self.data)
  return self
end

yatm_oku.OKU.StringMemory = StringMemory
