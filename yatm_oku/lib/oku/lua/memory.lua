--- @namespace yatm_oku.OKU

local ByteBuf = assert(foundation.com.ByteBuf.little)

---
--- Memory model used by OKU
---
--- @class LuaMemory
local LuaMemory = yatm_oku.OKU.MemoryBase:extends("oku.LuaMemory")
LuaMemory.Endian = {
  LITTLE = 0,
  BIG = 1,
}
do
  local ic = assert(LuaMemory.instance_class)

  --- Initializes a new binary memory, size is in bytes
  ---
  --- @spec #initialize(size: Integer): void
  function ic:initialize(size)
    ic._super.initialize(self)

    self.endian = LuaMemory.Endian.LITTLE
    self.is_lua = true

    assert(size > 0, "expected memory size to be greater than 0")
    --- @member m_size: Integer
    self.m_size = size
    --- @member m_data: Table
    self.m_data = {}

    -- Should indices be wrapped around to fit inside the address space
    -- Or an error raised?
    --- @member m_circular_access: Boolean
    self.m_circular_access = false

    for x = 0,self.m_size-1 do
      self.m_data[x] = 0
    end
    -- print("oku", "Lua.Memory", "allocated size=" .. self.m_size)
  end

  --- @spec #ptr(): Pointer
  function ic:ptr()
    return self.m_data
  end

  --- @spec #r_slice(index: Integer, size: Integer): Table
  function ic:r_slice(index, size)
    assert(index, "expected an index")
    assert(size, "expected a size")
    index = self:check_and_adjust_index(index, size)

    local result = {}
    for i = 1,size do
      result[i] = self.m_data[index + i - 1]
    end

    return result
  end

  --- @spec #r_blob(index: Integer, size: Integer): String
  function ic:r_blob(index, size)
    local slice = self:r_slice(index, size)
    return string.char(unpack(slice))
  end

  --- @spec #w_blob(index: Integer, blob: String): self
  function ic:w_blob(index, blob)
    assert(index, "expected an index")
    assert(blob, "expected a string blob")
    local size = #blob
    index = self:check_and_adjust_index(index, size)
    for i = 1,size do
      self.m_data[index + i - 1] = string.byte(blob, i)
    end
    return self
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

  --- @spec #w_i8(index: Integer, value: Integer): self
  function ic:w_i8(index, value)
    assert(index, "expected index")
    assert(value, "expected value")

    index = self:check_and_adjust_index(index, 1)
    if value < 0 then
      value = value + 256
    end
    value = value % 256
    self.m_data[index] = value
    return self
  end

  --- @spec #r_i8(index: Integer): Integer
  function ic:r_i8(index)
    index = self:check_and_adjust_index(index, 1)
    local byte = self.m_data[index]
    if byte < 128 then
      return byte
    end

    return byte - 256
  end

  --- @spec #w_u8(index: Integer, value: Integer): self
  function ic:w_u8(index, value)
    assert(type(value) == "number")
    index = self:check_and_adjust_index(index, 1)
    value = value % 256
    self.m_data[index] = value
    return self
  end

  --- @spec #r_u8(index: Integer): Integer
  function ic:r_u8(index)
    index = self:check_and_adjust_index(index, 1)
    return self.m_data[index]
  end

  --- @spec #r_u16(index: Integer): Integer
  function ic:r_u16(index)
    index = self:check_and_adjust_index(index, 2)
    local hi
    local lo
    if self.endian == LuaMemory.Endian.LITTLE then
      lo = self.m_data[index]
      hi = self.m_data[index + 1]
    else
      hi = self.m_data[index]
      lo = self.m_data[index + 1]
    end

    return hi * 256 + lo
  end

  --- @spec #r_u32(index: Integer): Integer
  function ic:r_u32(index)
    index = self:check_and_adjust_index(index, 4)
    local a
    local b
    local c
    local d
    if self.endian == LuaMemory.Endian.LITTLE then
      a = self.m_data[index]
      b = self.m_data[index + 1]
      c = self.m_data[index + 2]
      d = self.m_data[index + 3]
    else
      d = self.m_data[index]
      c = self.m_data[index + 1]
      b = self.m_data[index + 2]
      a = self.m_data[index + 3]
    end

    --- Magic numbers are powers of 2, being 2^24, 2^16 and 2^8
    return d * 0x1000000 * c * 0x10000 + b * 0x100 + a
  end

  --- @spec #r_bytes(index: Integer, size: Integer)
  function ic:r_bytes(index, size)
    assert(type(size) == "number", "expected size")

    index = self:check_and_adjust_index(index, size)

    local idx = 0
    local result = {}
    for i = 0,size-1 do
      idx = idx + 1
      result[idx] = self.m_data[index + i]
    end
    return result
  end

  --- @spec #bindump(Stream): (bytes_written: Integer, error: Any)
  function ic:bindump(stream)
    local bytes_written = 0
    local bw
    local err
    local success
    if self.endian == LuaMemory.Endian.LITTLE then
      bw = ByteBuf:write(stream, "le")
      bytes_written = bytes_written + bw
    else
      bw = ByteBuf:write(stream, "be")
      bytes_written = bytes_written + bw
    end

    bw = ByteBuf:w_u32(stream, self.m_size)
    bytes_written = bytes_written + bw

    if self.m_size > 0 then
      for i = 0,self.m_size-1 do
        success, err = stream:write(string.char(self.m_data[i]))
        if success then
          bytes_written = bytes_written + 1
        else
          return bytes_written, err
        end
      end
    end

    return bytes_written, nil
  end

  --- @spec #binload(Stream): (self, bytes_read: Integer)
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

    assert(#memory_blob == self.m_size, "expected blob size to match declared size")

    if memory_bo == "le" then
      assert(self.endian == LuaMemory.Endian.LITTLE, "expected little endianess")
    elseif memory_bo == "be" then
      assert(self.endian == LuaMemory.Endian.BIG, "expected big endianess")
    end

    self.m_data = {}
    for i = 0,self.m_size-1 do
      self.m_data[i] = string.byte(memory_blob, i + 1)
    end

    return self, bytes_read
  end

  --- @override
  --- @spec #memcpy(addr1: Integer, addr2: Integer, len: Integer): self
  function ic:memcpy(addr1, addr2, len)
    for i = 0,len-1 do
      self.m_data[addr2 + i] = self.m_data[addr1 + i]
    end
    return self
  end

  -- for type_name, size in pairs(types) do
  --   ic["r_" .. type_name] = function (self, index)
  --     index = self:check_and_adjust_index(index, size)
  --     ffi.copy(self.m_cell, self.m_data + index, size)
  --     return self.m_cell[type_name][0]
  --   end

  --   ic["w_" .. type_name] = function (self, index, value)
  --     index = self:check_and_adjust_index(index, size)
  --     self.m_cell[type_name][0] = value
  --     ffi.copy(self.m_data + index, self.m_cell, size)
  --     return self
  --   end
  -- end
end

yatm_oku.OKU.LuaMemory = assert(LuaMemory)
