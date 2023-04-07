--- @namespace yatm_oku.OKU

-- yatm_oku will remove ffi from its global object before finishing init,
-- therefore we need to keep a reference here instead
local ffi = yatm_oku.ffi

if not ffi then
  yatm.error("cannot create FFIMemory module, need ffi")
  return
end

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

local ByteBuf = assert(foundation.com.ByteBuf.little)

---
--- Memory model used by OKU
---
--- @class Memory
local FFIMemory = yatm_oku.OKU.MemoryBase:extends("oku.FFIMemory")
do
  local ic = assert(FFIMemory.instance_class)

  --- Initializes a new binary memory, size is in bytes
  ---
  --- @spec #initialize(size: Integer): void
  function ic:initialize(size)
    ic._super.initialize(self)

    assert(size > 0, "expected memory size to be greater than 0")
    self.is_ffi = true
    self.m_size = size
    self.m_data = assert(ffi.new("uint8_t[?]", self.m_size))
    self.m_cell = assert(ffi.new("union yatm_oku_memory_cell32"))
    -- Should indices be wrapped around to fit inside the address space
    -- Or an error raised?
    self.m_circular_access = false
    ffi.fill(self.m_data, self.m_size, 0)
    -- print("oku", "FFI.Memory", "allocated size=" .. self.m_size)
  end

  --- @spec #ptr(): Pointer
  function ic:ptr()
    return self.m_data
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
    ic["r_" .. type_name] = function (self, index)
      index = self:check_and_adjust_index(index, size)
      ffi.copy(self.m_cell, self.m_data + index, size)
      return self.m_cell[type_name][0]
    end

    ic["w_" .. type_name] = function (self, index, value)
      index = self:check_and_adjust_index(index, size)
      self.m_cell[type_name][0] = value
      ffi.copy(self.m_data + index, self.m_cell, size)
      return self
    end
  end

  function ic:r_blob(index, size)
    index = self:check_and_adjust_index(index, size)
    return ffi.string(self.m_data + index, size)
  end

  function ic:w_blob(index, blob)
    assert(index, "expected an index")
    assert(blob, "expected a string blob")
    local size = #blob
    index = self:check_and_adjust_index(index, size)
    ffi.copy(self.m_data + index, blob, size)
    return self
  end

  function ic:fill(value)
    ffi.fill(self.m_data, self.m_size, value)
    return self
  end

  function ic:fill_slice(index, size, value)
    index = self:check_and_adjust_index(index, size)
    ffi.fill(self.m_data + index, size, value)
    return self
  end

  --- @spec #r_bytes(index: Integer, size: Integer)
  function ic:r_bytes(index, size)
    index = self:check_and_adjust_index(index, size)
    return {string.byte(ffi.string(self.m_data + index, size), 1, -1)}
  end

  function ic:w_bytes(index, value)
    if type(value) == "string" then
      local size = #value
      index = self:check_and_adjust_index(index, size)
      ffi.copy(self.m_data + index, value, size)
    elseif type(value) == "number" then
      index = self:check_and_adjust_index(index, 1)
      self.m_data[index] = value
    elseif type(value) == "table" then
      -- all is well
      local size = #value
      if size > 0 then
        local end_index = index + size - 1
        local i = 1
        for j = index,end_index do
          j = self:check_and_adjust_index(j, 1)
          self.m_data.u8[j] = value[i]
          i = i + 1
        end
      end
    end
    return self
  end

  function ic:upload(blob)
    ffi.copy(self.m_data, blob)
    return self
  end

  --
  -- Binary Serialization
  --

  --- @spec #bindump(Stream): (bytes_written: Integer, error: Any)
  function ic:bindump(stream)
    local bytes_written = 0
    local bw
    if ffi.abi("le") then
      bw = ByteBuf:write(stream, "le")
      bytes_written = bytes_written + bw
    else
      bw = ByteBuf:write(stream, "be")
      bytes_written = bytes_written + bw
    end

    bw = ByteBuf:w_u32(stream, self.m_size)
    bytes_written = bytes_written + bw

    if self.m_size > 0 then
      local blob = ffi.string(self.m_data, self.m_size)
      assert(#blob == self.m_size, "expected blob to be the same size")
      bw = ByteBuf:write(stream, blob, self.m_size)
      bytes_written = bytes_written + bw
    end
    return bytes_written, nil
  end

  function ic:binload(stream)
    local bytes_read = 0

    local memory_bo, br = ByteBuf:read(stream, 2)
    bytes_read = bytes_read + br

    local memory_size, br = ByteBuf:r_u32(stream)
    bytes_read = bytes_read + br

    if memory_size ~= self.m_size then
      error("memory size mismatch expected=" .. self.m_size .. " got=" .. memory_size)
    end

    local memory_blob, br = ByteBuf:read(stream, memory_size)
    bytes_read = bytes_read + br

    if memory_bo == "le" then
      -- the memory was dumped from a little endian machine
      if ffi.abi("le") then
        -- and we're running on an LE machine, thank goodness
        ffi.copy(self.m_data, memory_blob, memory_size)
      else
        -- oh snap, no, no, no
        error("CRITICAL: Cannot restore little-endian memory dump in a big-endian host system")
      end
    elseif memory_bo == "be" then
      -- the memory was dumped from a big endian machine
      if ffi.abi("be") then
        -- and we're running on an BE machine, yay!, wait, wat, that's rare
        ffi.copy(self.m_data, memory_blob, memory_size)
      else
        -- well, whoops
        error("CRITICAL: Cannot restore big-endian memory dump in a little-endian host system")
      end
    end
    return self, bytes_read
  end
end

yatm_oku.OKU.FFIMemory = assert(FFIMemory)
