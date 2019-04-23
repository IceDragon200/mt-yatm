local BinaryMemory = yatm_core.Class:extends()
local m = assert(BinaryMemory.instance_class)

if not yatm_oku.ffi then
  error("BinaryMemory requires FFI, please add yatm_oku to your trusted mods list, or use a different memory model.")
end

-- yatm_oku will remove ffi from it's global object before finishing init,
-- therefore we need to keep a reference here instead
local ffi = yatm_oku.ffi

function m:initialize(size)
  self.size = size
  -- yes, I'm using short instead of char here, I don't want to deal with sign juggling
  -- It's easier to artificially restrict the size before it's stored than it is to switch between signed and unsigned
  self.data = assert(ffi.new("int8_t[?]", size))
end

function m:check_bounds(index, len)
  assert(index >= 0, "expected index to greater than or equal to 0")
  assert(index < self.size, "expected index to be less than size")
  if len then
    local end_index = index + len
    assert(end_index <= self.size, "expected end index to be inside memory")
  end
end

function m:i8(index)
  self:check_bounds(index)
  return self.data[index]
end

function m:w_i8(index, value)
  self:check_bounds(index)
  self.data[index] = value
  return self
end

function m:w_i8b(index, char)
  self:check_bounds(index)
  local value = string.byte(char, 1, 1)
  self.data[index] = value
  return self
end

function m:bytes(index, len)
  len = len or 1
  self:check_bounds(index, len)
  local result = {}
  local i = 1
  for j = index,index+len-1 do
    result[i] = self.data[j]
    i = i + 1
  end
  return result
end

function m:put_bytes(index, value)
  self:check_bounds(index)

  if type(value) == "string" then
    value = {string.byte(value, 1, #value)}
  elseif type(value) == "number" then
    value = {value}
  elseif type(value) == "table" then
    -- all is well
  end

  local len = #value
  if len > 0 then
    local end_index = index + len - 1
    assert(end_index < self.size, "expected end_index to be less than size")
    local i = 1
    for j = index,end_index do
      self.data[j] = value[i]
      i = i + 1
    end
  end
  return self
end

yatm_oku.OKU.BinaryMemory = BinaryMemory
