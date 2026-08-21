--- @namespace yatm_oku.OKU

-- yatm_oku will remove ffi from its global object before finishing init,
-- therefore we need to keep a reference here instead
local ffi = yatm_oku.ffi

if not ffi then
  yatm.error("cannot create FFIMemory module, need ffi")
  return
end

local ByteBuf = assert(foundation.com.ByteBuf.little)
local floor = assert(math.floor)

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

  --- @spec #r_u8(index: Integer): Integer
  function ic:r_u8(index)
    index = self:check_and_adjust_index(index, 1)
    return self.m_data[index]
  end

  --- @spec #w_u8(index: Integer, value: Integer): Integer
  function ic:w_u8(index, value)
    index = self:check_and_adjust_index(index, 1)
    self.m_data[index] = value
    return self
  end

  function ic:r_i8(index)
    local value = self:r_u8(index)
    return value < 0x80 and value or value - 0x100
  end
  ic.w_i8 = ic.w_u8

  function ic:r_le_u16(index)
    index = self:check_and_adjust_index(index, 2)
    local d = self.m_data
    return d[index] + d[index + 1] * 0x100
  end

  function ic:r_be_u16(index)
    index = self:check_and_adjust_index(index, 2)
    local d = self.m_data
    return d[index] * 0x100 + d[index + 1]
  end

  function ic:w_le_u16(index, value)
    index = self:check_and_adjust_index(index, 2)
    local d = self.m_data
    d[index] = value % 0x100
    d[index + 1] = floor(value / 0x100) % 0x100
    return self
  end

  function ic:w_be_u16(index, value)
    index = self:check_and_adjust_index(index, 2)
    local d = self.m_data
    d[index] = floor(value / 0x100) % 0x100
    d[index + 1] = value % 0x100
    return self
  end

  function ic:r_le_i16(index)
    local value = self:r_le_u16(index)
    return value < 0x8000 and value or value - 0x10000
  end

  function ic:r_be_i16(index)
    local value = self:r_be_u16(index)
    return value < 0x8000 and value or value - 0x10000
  end
  ic.w_le_i16 = ic.w_le_u16
  ic.w_be_i16 = ic.w_be_u16

  function ic:r_le_u32(index)
    index = self:check_and_adjust_index(index, 4)
    local d = self.m_data
    return d[index]
      + d[index + 1] * 0x100
      + d[index + 2] * 0x10000
      + d[index + 3] * 0x1000000
  end

  function ic:r_be_u32(index)
    index = self:check_and_adjust_index(index, 4)
    local d = self.m_data
    return d[index] * 0x1000000
      + d[index + 1] * 0x10000
      + d[index + 2] * 0x100
      + d[index + 3]
  end

  function ic:w_le_u32(index, value)
    index = self:check_and_adjust_index(index, 4)
    local d = self.m_data
    d[index] = value % 0x100
    d[index + 1] = floor(value / 0x100) % 0x100
    d[index + 2] = floor(value / 0x10000) % 0x100
    d[index + 3] = floor(value / 0x1000000) % 0x100
    return self
  end

  function ic:w_be_u32(index, value)
    index = self:check_and_adjust_index(index, 4)
    local d = self.m_data
    d[index] = floor(value / 0x1000000) % 0x100
    d[index + 1] = floor(value / 0x10000) % 0x100
    d[index + 2] = floor(value / 0x100) % 0x100
    d[index + 3] = value % 0x100
    return self
  end

  function ic:r_le_i32(index)
    local value = self:r_le_u32(index)
    return value < 0x80000000 and value or value - 0x100000000
  end

  function ic:r_be_i32(index)
    local value = self:r_be_u32(index)
    return value < 0x80000000 and value or value - 0x100000000
  end
  ic.w_le_i32 = ic.w_le_u32
  ic.w_be_i32 = ic.w_be_u32

  if ffi.abi("le") then
    ic.r_u16, ic.w_u16 = ic.r_le_u16, ic.w_le_u16
    ic.r_i16, ic.w_i16 = ic.r_le_i16, ic.w_le_i16
    ic.r_u32, ic.w_u32 = ic.r_le_u32, ic.w_le_u32
    ic.r_i32, ic.w_i32 = ic.r_le_i32, ic.w_le_i32
  else
    ic.r_u16, ic.w_u16 = ic.r_be_u16, ic.w_be_u16
    ic.r_i16, ic.w_i16 = ic.r_be_i16, ic.w_be_i16
    ic.r_u32, ic.w_u32 = ic.r_be_u32, ic.w_be_u32
    ic.r_i32, ic.w_i32 = ic.r_be_i32, ic.w_be_i32
  end

  local int64_ptr = ffi.typeof("int64_t *")
  local uint64_ptr = ffi.typeof("uint64_t *")
  local float_ptr = ffi.typeof("float *")
  local double_ptr = ffi.typeof("double *")

  function ic:r_i64(index)
    index = self:check_and_adjust_index(index, 8)
    return ffi.cast(int64_ptr, self.m_data + index)[0]
  end

  function ic:w_i64(index, value)
    index = self:check_and_adjust_index(index, 8)
    ffi.cast(int64_ptr, self.m_data + index)[0] = value
    return self
  end

  function ic:r_u64(index)
    index = self:check_and_adjust_index(index, 8)
    return ffi.cast(uint64_ptr, self.m_data + index)[0]
  end

  function ic:w_u64(index, value)
    index = self:check_and_adjust_index(index, 8)
    ffi.cast(uint64_ptr, self.m_data + index)[0] = value
    return self
  end

  function ic:r_f(index)
    index = self:check_and_adjust_index(index, 4)
    return ffi.cast(float_ptr, self.m_data + index)[0]
  end

  function ic:w_f(index, value)
    index = self:check_and_adjust_index(index, 4)
    ffi.cast(float_ptr, self.m_data + index)[0] = value
    return self
  end

  function ic:r_d(index)
    index = self:check_and_adjust_index(index, 8)
    return ffi.cast(double_ptr, self.m_data + index)[0]
  end

  function ic:w_d(index, value)
    index = self:check_and_adjust_index(index, 8)
    ffi.cast(double_ptr, self.m_data + index)[0] = value
    return self
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
          self.m_data[j] = value[i]
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
