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
  float     f[1];

  int32_t i32s;
  uint32_t u32s;
};
]]

-- Initializes a new binary memory, size is in bytes
-- @spec initialize(size :: integer) :: void
function m:initialize(size)
  self.m_size = size
  self.m_data = assert(ffi.new("uint8_t[?]", self.m_size))
  self.m_cell = assert(ffi.new("union yatm_oku_memory_cell32"))
  ffi.fill(self.m_data, self.m_size, 0)
end

function m:check_bounds(index, len)
  len = len or 1
  assert(index >= 0, "expected index to greater than or equal to 0")
  local end_index = index + len
  assert(end_index <= self.m_size, "expected end index to be inside memory (got:" .. end_index .. ")")
end

local types = {
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
}
for type_name, size in pairs(types) do
  m["r_" .. type_name] = function (self, index)
    self:check_bounds(index, size)
    ffi.copy(self.m_cell, self.m_data + index, size)
    return self.m_cell[type_name][0]
  end

  m["w_" .. type_name] = function (self, index, value)
    self:check_bounds(index, size)
    self.m_cell[type_name][0] = value
    ffi.copy(self.m_data + index, self.m_cell, size)
    return self
  end
end

function m:w_i8b(index, char)
  return self:w_u8(index, string.byte(char))
end

function m:r_blob(index, size)
  self:check_bounds(index, size)
  return ffi.string(self.m_data + index, size)
end

function m:w_blob(index, blob)
  assert(index, "expected an index")
  assert(blob, "expected a string blob")
  local size = #blob
  self:check_bounds(index, size)
  ffi.copy(self.m_data + index, blob, size)
  return self
end

function m:fill_slice(index, size, value)
  self:check_bounds(index, size)
  ffi.fill(self.m_data + index, size, value)
  return self
end

function m:r_bytes(index, size)
  return {string.byte(ffi.string(self.m_data + index, size), 1, -1)}
end

function m:w_bytes(index, value)
  if type(value) == "string" then
    local size = #value
    self:check_bounds(index, size)
    ffi.copy(self.m_data + index, value, size)
  elseif type(value) == "number" then
    self:check_bounds(index, 1)
    self.m_data[index] = value
  elseif type(value) == "table" then
    -- all is well
    local size = #value
    if size > 0 then
      local end_index = index + size - 1
      local i = 1
      for j = index,end_index do
        self:check_bounds(j, 1)
        self.m_data.u8[index] = value[i]
        i = i + 1
      end
    end
  end
  return self
end

function m:upload(blob)
  ffi.copy(self.m_data, blob)
  return self
end

--
-- Binary Serialization
--
local ByteBuf = assert(yatm_core.ByteBuf)

function m:bindump(stream)
  local bytes_written = 0
  if ffi.abi("le") then
    local bw = ByteBuf.write(stream, "le")
    bytes_written = bytes_written + bw
  else
    local bw = ByteBuf.write(stream, "be")
    bytes_written = bytes_written + bw
  end

  local blob = ffi.string(self.m_data, self.size)
  local bw = ByteBuf.write(stream, blob)
  bytes_written = bytes_written + bw
  return bytes_written, nil
end

function m:binload(stream)
  local bytes_read = 0
  local memory_bo, br = ByteBuf.read(stream, 2)
  bytes_read = bytes_read + br
  local memory_blob, br = ByteBuf.read(stream, memory_size)
  bytes_read = bytes_read + br
  if memory_bo == "le" then
    -- the memory was dumped from a little endian machine
    if ffi.abi("le") then
      -- and we're running on an LE machine, thank goodness
      ffi.copy(self.m_data, memory_blob)
    else
      -- oh snap, no, no, no
      error("CRITICAL: Cannot restore little-endian memory dump in a big-endian host system")
    end
  elseif memory_bo == "be" then
    -- the memory was dumped from a big endian machine
    if ffi.abi("be") then
      -- and we're running on an BE machine, yay!, wait, wat, that's rare
      ffi.copy(self.m_data, memory_blob)
    else
      -- well, whoops
      error("CRITICAL: Cannot restore big-endian memory dump in a little-endian host system")
    end
  end
  return self, bytes_read
end

yatm_oku.OKU.Memory = Memory
