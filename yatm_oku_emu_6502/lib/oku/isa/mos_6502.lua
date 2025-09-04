local ByteBuf = assert(foundation.com.ByteBuf.little)

local ffi = yatm_oku.ffi

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
    local bytes_written = 0
    local bw
    local err
    bw, err = ByteBuf:w_u32(stream, 1)
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Address Bus
    bw, err = ByteBuf:w_u16(stream, assigns.chip:get_register_ab())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Program Counter
    bw, err = ByteBuf:w_u16(stream, assigns.chip:get_register_pc())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Stack Pointer
    bw, err = ByteBuf:w_u8(stream, assigns.chip:get_register_sp())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Instruction Register
    bw, err = ByteBuf:w_u8(stream, assigns.chip:get_register_ir())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- A
    bw, err = ByteBuf:w_i8(stream, assigns.chip:get_register_a())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- X
    bw, err = ByteBuf:w_i8(stream, assigns.chip:get_register_x())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Y
    bw, err = ByteBuf:w_i8(stream, assigns.chip:get_register_y())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- SR
    bw, err = ByteBuf:w_i8(stream, assigns.chip:get_register_sr())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- State
    bw, err = ByteBuf:w_i8(stream, assigns.chip:get_state())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Cycles
    bw, err = ByteBuf:w_u32(stream, assigns.chip:get_cycles())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Operand
    bw, err = ByteBuf:w_i32(stream, assigns.chip:get_operand())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    return bytes_written, nil
  end

  function isa.binload(oku, assigns, stream)
    local bytes_read = 0
    local br
    local version
    version, br = ByteBuf:r_u32(stream)
    bytes_read = bytes_read + br

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

      ab, br = ByteBuf:r_u16(stream)
      bytes_read = bytes_read + br
      pc, br = ByteBuf:r_u16(stream)
      bytes_read = bytes_read + br
      sp, br = ByteBuf:r_u8(stream)
      bytes_read = bytes_read + br
      ir, br = ByteBuf:r_u8(stream)
      bytes_read = bytes_read + br
      a, br = ByteBuf:r_i8(stream)
      bytes_read = bytes_read + br
      x, br = ByteBuf:r_i8(stream)
      bytes_read = bytes_read + br
      y, br = ByteBuf:r_i8(stream)
      bytes_read = bytes_read + br
      sr, br = ByteBuf:r_i8(stream)
      bytes_read = bytes_read + br
      state, br = ByteBuf:r_i8(stream)
      bytes_read = bytes_read + br
      cycles, br = ByteBuf:r_u32(stream)
      bytes_read = bytes_read + br
      operand, br = ByteBuf:r_i32(stream)
      bytes_read = bytes_read + br

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
    return bytes_read
  end
end

yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/builder.lua")
yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/lexer.lua")
yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/parser.lua")
yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/assembler.lua")
