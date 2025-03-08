---
--- Base Memory Class
---
--- @class MemoryBase
local MemoryBase = foundation.com.Class:extends("oku.MemoryBase")
do
  local ic = assert(MemoryBase.instance_class)

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    --- @member is_lua: Boolean
    self.is_lua = false

    --- @member is_ffi: Boolean
    self.is_ffi = false
  end

  --- Sets the circular access flag in memory
  --- This causes overwrites to start back from the start when it overflows.
  ---
  --- @spec #set_circular_access(bool: Boolean): void
  function ic:set_circular_access(bool)
    self.m_circular_access = bool
  end

  --- @spec #size(): Integer
  function ic:size()
    return self.m_size
  end

  --- @spec #check_and_adjust_index(index: Integer, len: Integer): Integer
  function ic:check_and_adjust_index(index, len)
    if self.m_circular_access then
      return index % self.m_size
    else
      len = len or 1
      assert(index >= 0, "expected index to greater than or equal to 0")
      local end_index = index + len
      assert(end_index <= self.m_size, "expected end index to be inside memory (got:" .. end_index .. ")")
      return index
    end
  end

  --- @spec #w_i8b(index: Integer, char: String): self
  function ic:w_i8b(index, char)
    return self:w_u8(index, string.byte(char))
  end

  --- Default implementation of memcpy, this uses the existing r_u8 and w_u8 to copy cells
  --- Memory implementations can and are implored to overwrite this implementation to fit their
  --- needs.
  ---
  --- @spec #memcpy(addr1: Integer, addr2: Integer, len: Integer): self
  function ic:memcpy(addr1, addr2, len)
    for i = 0,len-1 do
      self:w_u8(addr2 + i, self:r_u8(addr1 + i))
    end
  end
end

yatm_oku.OKU.MemoryBase = assert(MemoryBase)
