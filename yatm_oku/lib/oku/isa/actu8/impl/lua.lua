local bit = assert(foundation.com.bit)
local band = assert(bit.band)
local bor = assert(bit.bor)
local bxor = assert(bit.bxor)
local floor = assert(math.floor)
local ACTU8 = assert(yatm_oku.OKU.isa.ACTU8)
--- @namespace yatm_oku.OKU.isa.ACTU8

--- @class LuaChip
ACTU8.LuaChip = foundation.com.Class:extends("yatm_oku.OKU.isa.ACTU8.LuaChip")
do
  local ic = ACTU8.LuaChip.instance_class

  --- @override
  --- @spec #initializealize(): void
  function ic:initialize()
    ic._super.initialize(self)
    self:reset()
  end

  --- Destroy any allocated state, but this is the lua implementation
  --- there is nothing to dispose.
  --- @spec #dispose(): void
  function ic:dispose()
  end

  --- Resets machine state.
  --- @spec #reset(): self
  function ic:reset()
    self.a = 0
    self.pc = 0
    self.sp = 255
    self.flags = {
      zero = 0,
      borrow = 0,
      carry = 0,
      interrupt = 0,
      halt = 0,
      fault = 0,
    }
    self.fc = ACTU8.FAULT_OK
    return self
  end

  --- @spec #is_halted(): Boolean
  function ic:is_halted()
    return self.flags.halt > 0
  end

  --- @spec #step(memory: Memory): Integer
  function ic:step(memory)
    if self.flags.fault > 0 then
      return self.fc
    end

    if self.flags.halt > 0 then
      return ACTU8.FAULT_HALTED
    end
    local pc = self.pc
    local ins = memory:r_u8(pc)
    local size = memory:size()
    local stack_top = size - 256
    local ram_start = size - 512
    local io_start = size - 768
    local check_zero = false

    if ins == 0x00 then -- NOP
      pc = pc + 1
    elseif ins == 0x01 then -- HALT
      pc = pc + 1
      self.flags.halt = 1
    elseif ins == 0x10 then -- LDI <imm>
      local imm = memory:r_u8(pc + 1)
      pc = pc + 2
      self.a = imm
      check_zero = true
    elseif ins == 0x11 then -- LDA <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      local value = memory:r_u8(ram_start + addr8)
      self.a = value
      check_zero = true
    elseif ins == 0x12 then -- STA <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      memory:w_u8(ram_start + addr8, self.a)
    elseif ins == 0x13 then -- PUSH
      pc = pc + 1
      local sp = self.sp - 1
      if sp < 0 then
        self.flags.fault = 1
        self.fc = ACTU8.FAULT_STACK_OVERFLOW
      else
        self.sp = sp
        memory:w_u8(stack_top + sp, self.a)
      end
    elseif ins == 0x14 then -- POP
      pc = pc + 1
      local sp = self.sp + 1
      if sp > 255 then
        self.flags.fault = 1
        self.fc = ACTU8.FAULT_STACK_UNDERFLOW
      else
        self.a = memory:r_u8(stack_top + self.sp)
        self.sp = sp
        check_zero = true
      end
    elseif ins == 0x20 then -- ADD <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      local value = memory:r_u8(ram_start + addr8)
      local a = self.a + value
      self.flags.borrow = 0
      if a > 255 then
        self.flags.carry = 1
        self.a = a - 256
      else
        self.flags.carry = 0
        self.a = a
      end
      check_zero = true
    elseif ins == 0x21 then -- SUB <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      local value = memory:r_u8(ram_start + addr8)
      local a = self.a - value
      self.flags.carry = 0
      if a < 0 then
        self.flags.borrow = 1
        self.a = a + 256
      else
        self.flags.borrow = 0
        self.a = a
      end
      check_zero = true
    elseif ins == 0x22 then -- CMP <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      local value = memory:r_u8(ram_start + addr8)
      if self.a == value then
        self.flags.zero = 1
        self.flags.borrow = 0
        self.flags.carry = 0
      elseif self.a > value then
        self.flags.zero = 0
        self.flags.borrow = 0
        self.flags.carry = 1
      elseif self.a < value then
        self.flags.zero = 0
        self.flags.borrow = 1
        self.flags.carry = 0
      end
    elseif ins == 0x30 then -- AND <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      local value = memory:r_u8(ram_start + addr8)
      self.a = band(self.a, value)
      check_zero = true
    elseif ins == 0x31 then -- OR <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      local value = memory:r_u8(ram_start + addr8)
      self.a = bor(self.a, value)
      check_zero = true
    elseif ins == 0x32 then -- XOR <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      local value = memory:r_u8(ram_start + addr8)
      self.a = bxor(self.a, value)
      check_zero = true
    elseif ins == 0x40 then -- CLZ
      pc = pc + 1
      self.flags.zero = 0
    elseif ins == 0x41 then -- CLC
      pc = pc + 1
      self.flags.carry = 0
    elseif ins == 0x42 then -- CLB
      pc = pc + 1
      self.flags.borrow = 0
    elseif ins == 0x43 then -- CLI
      pc = pc + 1
      self.flags.interrupt = 0
    elseif ins == 0x50 then -- JMP <addr16>
      pc = pc + 1
      goto jump
    elseif ins == 0x51 then -- CALL <addr16>
      if self.sp < 2 then
        self.flags.fault = 1
        self.fc = ACTU8.FAULT_STACK_OVERFLOW
      else
        local ret_pc = pc + 3
        local lo = ret_pc % 256
        local hi = floor(ret_pc / 256)
        memory:w_u8(stack_top + self.sp - 1, lo)
        memory:w_u8(stack_top + self.sp - 2, hi)
        self.sp = self.sp - 2
        pc = pc + 1
        goto jump
      end
    elseif ins == 0x52 then -- RET
      if self.sp > 253 then
        self.flags.fault = 1
        self.fc = ACTU8.FAULT_STACK_UNDERFLOW
      else
        local hi = memory:r_u8(stack_top + self.sp)
        local lo = memory:r_u8(stack_top + self.sp + 1)
        pc = hi * 256 + lo
        self.sp = self.sp + 2
      end
    elseif ins == 0x60 then -- JZ <addr16>
      if self.flags.zero > 0 then
        pc = pc + 1
        goto jump
      else
        pc = pc + 3
      end
    elseif ins == 0x61 then -- JNZ <addr16>
      if self.flags.zero == 0 then
        pc = pc + 1
        goto jump
      else
        pc = pc + 3
      end
    elseif ins == 0x62 then -- JC <addr16>
      if self.flags.carry > 0 then
        pc = pc + 1
        goto jump
      else
        pc = pc + 3
      end
    elseif ins == 0x63 then -- JNC <addr16>
      if self.flags.carry == 0 then
        pc = pc + 1
        goto jump
      else
        pc = pc + 3
      end
    elseif ins == 0x64 then -- JB <addr16>
      if self.flags.borrow > 0 then
        pc = pc + 1
        goto jump
      else
        pc = pc + 3
      end
    elseif ins == 0x65 then -- JNB <addr16>
      if self.flags.borrow == 0 then
        pc = pc + 1
        goto jump
      else
        pc = pc + 3
      end
    elseif ins == 0x66 then -- JI <addr16>
      if self.flags.interrupt > 0 then
        pc = pc + 1
        goto jump
      else
        pc = pc + 3
      end
    elseif ins == 0x67 then -- JNI <addr16>
      if self.flags.interrupt == 0 then
        pc = pc + 1
        goto jump
      else
        pc = pc + 3
      end
    elseif ins == 0x70 then -- IN <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      local value = memory:r_u8(io_start + addr8)
      self.a = value
      check_zero = true
    elseif ins == 0x71 then -- OUT <addr8>
      local addr8 = memory:r_u8(pc + 1)
      pc = pc + 2
      memory:w_u8(io_start + addr8, self.a)
    else
      self.flags.fault = 1
      self.fc = ACTU8.FAULT_UNRECOGNIZED_INSTRUCTION
    end
  ::check_zero::
    if check_zero then
      if self.a == 0 then
        self.flags.zero = 1
      else
        self.flags.zero = 0
      end
    end
    goto after
  ::jump::
    do
      local lo = memory:r_u8(pc)
      local hi = memory:r_u8(pc + 1)
      self.pc = lo + hi * 256
    end
  ::after::
    self.pc = pc
    return 0
  end

  --- Unpacks an integer generated from #packed_flags/0 into the flags register.
  --- @spec unpack_flags(flags: Integer): self
  function ic:unpack_flags(flags)
    self.flags.zero = flags % 2
    flags = floor(flags / 2)
    self.flags.borrow = flags % 2
    flags = floor(flags / 2)
    self.flags.carry = flags % 2
    flags = floor(flags / 2)
    self.flags.interrupt = flags % 2
    flags = floor(flags / 2)
    self.flags.halt = flags % 2
    flags = floor(flags / 2)
    self.flags.fault = flags % 2
    return self
  end

  --- Packs the individuals flags in the flags register into a single integer.
  --- @spec #packged_flags(): Integer
  function ic:packed_flags()
    return self.flags.zero +
      self.flags.borrow * 2 +
      self.flags.carry * 4 +
      self.flags.interrupt * 8 +
      self.flags.halt * 16 +
      self.flags.fault * 32
  end
end
