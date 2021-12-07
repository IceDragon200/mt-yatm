local ByteBuf = assert(foundation.com.ByteBuf.little)

local ffi = yatm_oku.ffi

yatm_oku.OKU.isa.MOS6502 = {
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

yatm_oku:require("lib/oku/isa/mos_6502/impl/lua.lua")
if ffi then
  minetest.log("info", "MOS6502 native implementation may be possible")
  yatm_oku:require("lib/oku/isa/mos_6502/impl/native.lua")

  if not yatm_oku.OKU.isa.MOS6502.has_native then
    minetest.log("warning", "MOS6502 native implementation was not loaded")
  end
else
  minetest.log("warning", "ffi unavailable, cannot use native MOS6502 implementation")
end

yatm_oku.OKU.isa.MOS6502.Chip = yatm_oku.OKU.isa.MOS6502.NativeChip or
                                yatm_oku.OKU.isa.MOS6502.LuaChip

local Chip = assert(yatm_oku.OKU.isa.MOS6502.Chip, "expected a chip implementation")

local code_table = {
  [0] = "ok",
  [1] = "invalid",
  [4] = "halt",
  [5] = "hang",
  [7] = "startup",
  [127] = "segfault",
}

local isa = yatm_oku.OKU.isa.MOS6502

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

function isa.step(oku, assigns)
  assigns.chip:set_memory(oku.memory:size(), oku.memory:ptr())
  local code = assigns.chip:step()

  if code_table[code] == "ok" or
     code_table[code] == "startup" then
    return true, nil
  else
    return false, code_table[code]
  end
end

function isa.bindump(oku, assigns, stream)
  local bytes_written = 0
  local bw, err = ByteBuf:w_u32(stream, 1)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Address Bus
  local bw, err = ByteBuf:w_u16(stream, assigns.chip:get_register_ab())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Program Counter
  local bw, err = ByteBuf:w_u16(stream, assigns.chip:get_register_pc())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Stack Pointer
  local bw, err = ByteBuf:w_u8(stream, assigns.chip:get_register_sp())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Instruction Register
  local bw, err = ByteBuf:w_u8(stream, assigns.chip:get_register_ir())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- A
  local bw, err = ByteBuf:w_i8(stream, assigns.chip:get_register_a())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- X
  local bw, err = ByteBuf:w_i8(stream, assigns.chip:get_register_x())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Y
  local bw, err = ByteBuf:w_i8(stream, assigns.chip:get_register_y())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- SR
  local bw, err = ByteBuf:w_i8(stream, assigns.chip:get_register_sr())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- State
  local bw, err = ByteBuf:w_i8(stream, assigns.chip:get_state())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Cycles
  local bw, err = ByteBuf:w_u32(stream, assigns.chip:get_cycles())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Operand
  local bw, err = ByteBuf:w_i32(stream, assigns.chip:get_operand())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  return bytes_written, nil
end

function isa.binload(oku, assigns, stream)
  local bytes_read = 0
  local version, br = ByteBuf:r_u32(stream)
  bytes_read = bytes_read + br

  local chip = Chip:new()
  assigns.chip = chip

  if version == 1 then
    local ab, br = ByteBuf:r_u16(stream)
    local pc, br = ByteBuf:r_u16(stream)
    local sp, br = ByteBuf:r_u8(stream)
    local ir, br = ByteBuf:r_u8(stream)
    local a, br = ByteBuf:r_i8(stream)
    local x, br = ByteBuf:r_i8(stream)
    local y, br = ByteBuf:r_i8(stream)
    local sr, br = ByteBuf:r_i8(stream)
    local state, br = ByteBuf:r_i8(stream)
    local cycles, br = ByteBuf:r_u32(stream)
    local operand, br = ByteBuf:r_i32(stream)

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

yatm_oku:require("lib/oku/isa/mos_6502/builder.lua")
yatm_oku:require("lib/oku/isa/mos_6502/lexer.lua")
yatm_oku:require("lib/oku/isa/mos_6502/parser.lua")
yatm_oku:require("lib/oku/isa/mos_6502/assembler.lua")
