local Memory = yatm_core.Class:extends()
local m = assert(Memory.instance_class)

-- yatm_oku will remove ffi from it's global object before finishing init,
-- therefore we need to keep a reference here instead
local ffi = assert(yatm_oku.ffi)

ffi.cdef[[
union yatm_oku_memory_cell32 {
  char      c[4];
  int8_t   i8[4];
  uint8_t  u8[4];
  int16_t  i16[2];
  uint16_t u16[2];
  int32_t  i32[1];
  uint32_t u32[1];
  float      f[1];
};
]]

local UNION_BYTE_SIZE = 4

-- Initializes a new binary memory, size is in bytes
-- @spec initialize(size :: integer) :: void
function m:initialize(size)
  self.size = size
  self.data_size = math.floor(self.size / UNION_BYTE_SIZE) -- the data size is a 1/4 of the given size

  assert((self.data_size * UNION_BYTE_SIZE) == self.size, "size be a factor of " .. UNION_BYTE_SIZE)
  -- yes, I'm using short instead of char here, I don't want to deal with sign juggling
  -- It's easier to artificially restrict the size before it's stored than it is to switch between signed and unsigned
  self.data = assert(ffi.new("union yatm_oku_memory_cell32[?]", self.data_size))
end

function m:check_bounds(index, len)
  len = len or 1
  assert(index >= 0, "expected index to greater than or equal to 0")
  local end_index = index + len
  assert(end_index <= self.size, "expected end index to be inside memory")
end
function m:adjust_and_check_bounds(local_index, size, len)
  len = len or 1
  local byte_index = local_index * size
  local byte_len = len * size
  self:check_bounds(byte_index, byte_len)
  local cell_size = math.floor(UNION_BYTE_SIZE / size)
  local cell_index = math.floor(local_index / cell_size)
  local cell_offset = local_index % cell_size

  return cell_index, cell_offset
end

for type_name, size in pairs({
  i8 = 1,
  i16 = 2,
  i32 = 4,
  i64 = 8,
  u8 = 1,
  u16 = 2,
  u32 = 4,
  u64 = 8,
  f = 4,
  d = 8,
}) do
  m[type_name] = function (self, index)
    local i, o = self:adjust_and_check_bounds(index, size)
    return self.data[i][type_name][o]
  end

  m["w_" .. type_name] = function (self, index, value)
    local i, o = self:adjust_and_check_bounds(index, size)
    self.data[i][type_name][o] = value
    return self
  end
end

function m:w_i8b(index, char)
  local i, o = self:adjust_and_check_bounds(index, 1)
  local value = string.byte(char, 1, 1)
  self.data[i].c[o] = value
  return self
end

function m:bytes(index, len)
  len = len or 1
  local result = {}
  local i = 1
  local end_index = index + len - 1
  for j = index,end_index do
    local ci, co = self:adjust_and_check_bounds(j, 1)
    result[i] = self.data[ci].c[co]
    i = i + 1
  end
  return result
end

function m:put_bytes(index, value)
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
    local i = 1
    for j = index,end_index do
      local ci, co = self:adjust_and_check_bounds(j, 1)
      self.data[ci].c[co] = value[i]
      i = i + 1
    end
  end
  return self
end

yatm_oku.OKU.Memory = Memory
