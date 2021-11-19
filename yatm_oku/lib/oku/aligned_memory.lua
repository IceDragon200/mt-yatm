-- yatm_oku will remove ffi from it's global object before finishing init,
-- therefore we need to keep a reference here instead
local ffi = yatm_oku.ffi

if not ffi then
  yatm.error("cannot create memory module, need ffi")
  return
end

local ByteBuf = assert(foundation.com.ByteBuf)

local Memory = foundation.com.Class:extends("oku.AlignedMemory")
local m = assert(Memory.instance_class)

ffi.cdef[[
union yatm_oku_aligned_memory_cell32 {
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
-- @spec initialize(size: Integer): void
function m:initialize(size)
  self.size = size
  self.m_data_size = math.floor(self.size / UNION_BYTE_SIZE) -- the data size is a 1/4 of the given size

  assert((self.m_data_size * UNION_BYTE_SIZE) == self.size, "expected size to be a factor of " .. UNION_BYTE_SIZE)
  self.m_data = assert(ffi.new("union yatm_oku_aligned_memory_cell32[?]", self.m_data_size))
  ffi.fill(self.m_data, self.size, 0)
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
    return self.m_data[i][type_name][o]
  end

  m["w_" .. type_name] = function (self, index, value)
    local i, o = self:adjust_and_check_bounds(index, size)
    self.m_data[i][type_name][o] = value
    return self
  end
end

function m:w_i8b(index, char)
  local i, o = self:adjust_and_check_bounds(index, 1)
  local value = string.byte(char, 1, 1)
  self.m_data[i].c[o] = value
  return self
end

function m:fill_slice(index, len, value)
  ffi.fill(self.m_data + index, len, value)
  return self
end

function m:bytes(index, len)
  len = len or 1
  local result = {}
  local i = 1
  local end_index = index + len - 1
  for j = index,end_index do
    local ci, co = self:adjust_and_check_bounds(j, 1)
    result[i] = self.m_data[ci].c[co]
    i = i + 1
  end
  return result
end

function m:put_bytes(index, value)
  if type(value) == "string" then
    ffi.copy(self.m_data + index, value, #value)
  elseif type(value) == "number" then
    local ci, co = self:adjust_and_check_bounds(index, 1)
    self.m_data[ci].c[co] = value
  elseif type(value) == "table" then
    -- all is well
    local len = #value
    if len > 0 then
      local end_index = index + len - 1
      local i = 1
      for j = index,end_index do
        local ci, co = self:adjust_and_check_bounds(j, 1)
        self.m_data[ci].c[co] = value[i]
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
