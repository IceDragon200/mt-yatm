local BB_LE = assert(foundation.com.ByteBuf.LE)

local ffi = yatm_oku_emu_6502.ffi

local MOS6502 = {
  has_native = false,
  OK_CODE = 0,
  INVALID_CODE = 1,
  HALT_CODE = 4,
  HANG_CODE = 5,
  STARTUP_CODE = 7,
  SEGFAULT_CODE = 127,
  CPU_STATE_RESET = 1,
  CPU_STATE_RUN = 2,
  CPU_STATE_HANG = 3,
  NMI_VECTOR_PTR = 0xFFFA,
  RESET_VECTOR_PTR = 0xFFFC,
  IRQ_VECTOR_PTR = 0xFFFE,
  BREAK_VECTOR_PTR = 0xFFFE,
}

yatm_oku.OKU.isa.MOS6502 = MOS6502

yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/impl/lua.lua")
if ffi then
  core.log("info", "MOS6502 native implementation may be possible")
  yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/impl/native.lua")

  if not yatm_oku.OKU.isa.MOS6502.has_native then
    core.log("warning", "MOS6502 native implementation was not loaded")
  end
else
  core.log("warning", "ffi unavailable, cannot use native MOS6502 implementation")
end

yatm_oku.OKU.isa.MOS6502.Chip = yatm_oku.OKU.isa.MOS6502.NativeChip or
                                yatm_oku.OKU.isa.MOS6502.LuaChip

local Chip = assert(MOS6502.Chip, "expected a chip implementation")

local code_table = {
  [MOS6502.OK_CODE] = "ok",
  [MOS6502.INVALID_CODE] = "invalid",
  [MOS6502.HALT_CODE] = "halt",
  [MOS6502.HANG_CODE] = "hang",
  [MOS6502.STARTUP_CODE] = "startup",
  [MOS6502.SEGFAULT_CODE] = "segfault",
}

do
  local isa = MOS6502

  function isa.test()
    local chip = Chip:new{
      create_memory = true,
      memory_size = 0xFFFF
    }

    local status = chip:step()
    print("STATUS", status)

    chip:dispose()

    chip = nil
    mem = nil
  end

  function isa.init(oku, assigns)
    local chip = Chip:new()
    assigns.chip = chip
  end

  function isa.dispose(oku, assigns)
    assigns.chip:dispose()
    assigns.chip = nil
  end

  function isa.reset(oku, assigns)
    assigns.chip:set_state(isa.CPU_STATE_RESET)
  end

  function isa.load_com_binary(oku, assigns, blob)
    -- COM files are a raw binary executable format
    -- The executation starts at address 0x0100
    -- https://www.csc.depauw.edu/~bhoward/asmtut/asmtut11.html
    assigns.chip:set_register_pc(0x0100)

    oku:clear_memory_slice(0x0100, #blob)
    oku:w_memory_blob(0x0100, blob)
  end

  --- @spec step(OKU, assigns: Table): (Boolean, status: String)
  function isa.step(oku, assigns)
    assigns.chip:set_memory(oku.memory)

    local code = assigns.chip:step()

    if code == isa.OK_CODE or code == isa.STARTUP_CODE then
      return true, code
    else
      return false, code
    end
  end

  function isa.bindump(oku, assigns, stream)
    local abw = 0
    local bw
    local err
    bw, err = BB_LE:w_u32(stream, 1)
    abw = abw + bw
    if err then
      return abw, err
    end

    -- Address Bus
    bw, err = BB_LE:w_u16(stream, assigns.chip:get_register_ab())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- Program Counter
    bw, err = BB_LE:w_u16(stream, assigns.chip:get_register_pc())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- Stack Pointer
    bw, err = BB_LE:w_u8(stream, assigns.chip:get_register_sp())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- Instruction Register
    bw, err = BB_LE:w_u8(stream, assigns.chip:get_register_ir())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- A
    bw, err = BB_LE:w_i8(stream, assigns.chip:get_register_a())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- X
    bw, err = BB_LE:w_i8(stream, assigns.chip:get_register_x())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- Y
    bw, err = BB_LE:w_i8(stream, assigns.chip:get_register_y())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- SR
    bw, err = BB_LE:w_i8(stream, assigns.chip:get_register_sr())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- State
    bw, err = BB_LE:w_i8(stream, assigns.chip:get_state())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- Cycles
    bw, err = BB_LE:w_u32(stream, assigns.chip:get_cycles())
    abw = abw + bw
    if err then
      return abw, err
    end

    -- Operand
    bw, err = BB_LE:w_i32(stream, assigns.chip:get_operand())
    abw = abw + bw
    if err then
      return abw, err
    end

    return abw, nil
  end

  function isa.binload(oku, assigns, stream)
    local abr = 0
    local br
    local version
    version, br = BB_LE:r_u32(stream)
    abr = abr + br

    local chip = Chip:new()
    assigns.chip = chip

    if version == 1 then
      local ab
      local pc
      local sp
      local ir
      local a
      local x
      local y
      local sr
      local state
      local cycles
      local operand

      ab, br = BB_LE:r_u16(stream)
      abr = abr + br
      pc, br = BB_LE:r_u16(stream)
      abr = abr + br
      sp, br = BB_LE:r_u8(stream)
      abr = abr + br
      ir, br = BB_LE:r_u8(stream)
      abr = abr + br
      a, br = BB_LE:r_i8(stream)
      abr = abr + br
      x, br = BB_LE:r_i8(stream)
      abr = abr + br
      y, br = BB_LE:r_i8(stream)
      abr = abr + br
      sr, br = BB_LE:r_i8(stream)
      abr = abr + br
      state, br = BB_LE:r_i8(stream)
      abr = abr + br
      cycles, br = BB_LE:r_u32(stream)
      abr = abr + br
      operand, br = BB_LE:r_i32(stream)
      abr = abr + br

      assigns.chip:set_register_ab(ab)
      assigns.chip:set_register_pc(pc)
      assigns.chip:set_register_sp(sp)
      assigns.chip:set_register_ir(ir)
      assigns.chip:set_register_a(a)
      assigns.chip:set_register_x(x)
      assigns.chip:set_register_y(y)
      assigns.chip:set_register_sr(sr)

      assigns.chip:set_state(state)
      assigns.chip:set_cycles(cycles)
      assigns.chip:set_operand(operand)
    else
      error("unexpected version=" .. version)
    end
    return abr
  end
end

yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/builder.lua")
yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/lexer.lua")
yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/parser.lua")
yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/assembler.lua")
