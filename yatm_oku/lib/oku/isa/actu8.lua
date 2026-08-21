--
-- OKU's default ISA and Machine architecture.
--
local BB_LE = assert(foundation.com.ByteBuf.LE)

local ffi = yatm_oku.ffi

local ACTU8 = {
  has_native = false,

  PAGE_SIZE = 0x100,

  --
  -- Fault Codes
  --
  FAULT_OK = 0,
  FAULT_STACK_UNDERFLOW = 1,
  FAULT_STACK_OVERFLOW = 2,
  FAULT_UNRECOGNIZED_INSTRUCTION = 3,
  FAULT_ACCESS_VIOLATION = 4,
  FAULT_HALTED = 5, -- not really a fault, but it's also a signifier that the computer did nothing
  FAULT_SEGFAULT = 255,
}
yatm_oku.OKU.isa.ACTU8 = ACTU8

--- @spec io_start(memory_size: Integer): Integer
function ACTU8.io_start(memory_size)
  return memory_size - ACTU8.PAGE_SIZE * 3
end

--- @spec ram_start(memory_size: Integer): Integer
function ACTU8.ram_start(memory_size)
  return memory_size - ACTU8.PAGE_SIZE * 2
end

--- @spec stack_start(memory_size: Integer): Integer
function ACTU8.stack_start(memory_size)
  return memory_size - ACTU8.PAGE_SIZE
end

--- @spec io_address(memory_size: Integer, offset: Integer): Integer
function ACTU8.io_address(memory_size, offset)
  return ACTU8.io_start(memory_size) + offset
end

--- @spec ram_address(memory_size: Integer, offset: Integer): Integer
function ACTU8.ram_address(memory_size, offset)
  return ACTU8.ram_start(memory_size) + offset
end

--- @spec stack_address(memory_size: Integer, offset: Integer): Integer
function ACTU8.stack_address(memory_size, offset)
  return ACTU8.stack_start(memory_size) + offset
end

yatm_oku:require("lib/oku/isa/actu8/impl/lua.lua")
yatm_oku:require("lib/oku/isa/actu8/builder.lua")
yatm_oku:require("lib/oku/isa/actu8/assembler.lua")
ACTU8.Chip = assert(ACTU8.NativeChip or ACTU8.LuaChip, "expected a chip implementation")
local Chip = ACTU8.Chip

do
  local isa = ACTU8

  --- @spec init(oku: OKU, assigns: Table): void
  function isa.init(oku, assigns)
    local chip = Chip:new()
    assigns.chip = chip
  end

  --- @spec dispose(oku: OKU, assigns: Table): void
  function isa.dispose(oku, assigns)
    assigns.chip:dispose()
    assigns.chip = nil
  end

  --- @spec reset(oku: OKU, assigns: Table): void
  function isa.reset(oku, assigns)
    assigns.chip:reset()
  end

  --- @spec step(oku: OKU, assigns: Table): (Boolean, Number)
  function isa.step(oku, assigns)
    assigns.chip:step(oku.memory)
    return true, 0
  end

  --- @spec is_halted(oku: OKU, assigns: Table): Boolean
  function isa.is_halted(oku, assigns)
    return assigns.chip:is_halted()
  end

  --- @spec bindump(oku: OKU, assigns: Table, stream: Stream): (Number, error: String)
  function isa.bindump(oku, assigns, stream)
    local abw = 0
    local bw
    local err
    local chip = assigns.chip

    bw, err = BB_LE:w_u32(stream, 1)
    abw = abw + bw
    if err then
      return abw, err
    end

    bw, err = BB_LE:w_u8(stream, chip.a)
    abw = abw + bw
    if err then
      return abw, err
    end

    bw, err = BB_LE:w_u16(stream, chip.pc)
    abw = abw + bw
    if err then
      return abw, err
    end

    bw, err = BB_LE:w_u8(stream, chip.sp)
    abw = abw + bw
    if err then
      return abw, err
    end

    bw, err = BB_LE:w_u8(stream, chip:packed_flags())
    abw = abw + bw
    if err then
      return abw, err
    end

    bw, err = BB_LE:w_u8(stream, chip.fc)
    abw = abw + bw
    if err then
      return abw, err
    end

    return abw, nil
  end

  --- @spec binload(oku: OKU, assigns: Table, stream: Stream): Integer
  function isa.binload(oku, assigns, stream)
    local abr = 0
    local br
    local version
    version, br = BB_LE:r_u32(stream)
    abr = abr + br

    local chip = Chip:new()
    assigns.chip = chip

    if version == 1 then
      local a
      local pc
      local sp
      local flags
      local fc

      a, br = BB_LE:r_u8(stream)
      abr = abr + br
      pc, br = BB_LE:r_u16(stream)
      abr = abr + br
      sp, br = BB_LE:r_u8(stream)
      abr = abr + br
      flags, br = BB_LE:r_u8(stream)
      abr = abr + br
      fc, br = BB_LE:r_u8(stream)
      abr = abr + br

      chip.a = a
      chip.pc = pc
      chip.sp = sp
      chip:unpack_flags(flags)
      chip.fc = fc
    else
      error("unexpected version=" .. version)
    end
    return abr
  end
end
