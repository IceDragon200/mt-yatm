--[[
OKU's memory model using lua tables.
]]

local TableMemory = {
  mt = {}
}

function TableMemory.new(size)
  local memory = {}
  setmetatable(memory, { __index = TableMemory.mt })
  memory:initialize(size)
  return memory
end

function TableMemory.mt:initialize(size)
  self.size = size
  self.data = {}
  for i=1,size do
    self.data[i] = 0
  end
end

function TableMemory.mt:bytes(index, end_index)
  oku_assert(index >= 0, "expected index to greater than or equal to 0")
  oku_assert(index < self.size, "expected index to be less than size")
  local end_index = end_index or index
  oku_assert(end_index < self.size, "expected end_index to be less than size")
  local result = {}
  local i = 1
  for j=index,end_index do
    result[i] = self.data[j + 1]
    i = i + 1
  end
  return result
end

function TableMemory.mt:put_bytes(index, bytes)
  oku_assert(index >= 0, "expected index to greater than or equal to 0")
  oku_assert(index <= self.size, "expected index to be less than size")
  if type(bytes) == "string" then
    bytes = {string.byte(bytes, 1, #bytes)}
  elseif type(bytes) == "number" then
    bytes = {bytes}
  elseif type(bytes) == "table" then
    -- all is well
  end
  local len = #bytes
  if len > 0 then
    local end_index = index + len - 1
    oku_assert(end_index < self.size, "expected end_index to be less than size")
    local i = 1
    for j = index,end_index do
      self.data[j + 1] = bytes[i]
    end
  end
  return self
end

yatm_oku.OKU.TableMemory = TableMemory
