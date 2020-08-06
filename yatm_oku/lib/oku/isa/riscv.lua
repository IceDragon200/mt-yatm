--
-- Registers:
--   x0-x31
--   pc
--
local ffi = assert(yatm_oku.ffi)
local ByteBuf = assert(foundation.com.ByteBuf)
local StringBuffer = assert(foundation.com.StringBuffer)

yatm_oku.OKU.isa.RISCV = {}
local isa = yatm_oku.OKU.isa.RISCV

local function init_riscv_assigns(assigns)
  -- the registers
  assigns.registers = ffi.new("struct yatm_oku_registers32")

  --assigns._native = ffi.new("union yatm_oku_rv32i_ins")
  assigns._itype = ffi.new("union yatm_oku_rv32i_itypes")

  assigns._native = {
    i32 = 0,
    u32 = 0,
    head = {
      iflag = 0,
      opcode = 0,
      rest = 0,
    },
    r = {
      iflag = 0,
      opcode = 0,
      rd = 0,
      funct3 = 0,
      rs1 = 0,
      rs2 = 0,
      funct7 = 0,
    },
    i = {
      iflag = 0,
      opcode = 0,
      rd = 0,
      funct3 = 0,
      rs1 = 0,
      imm12 = 0,
      imm12lo = 0,
      imm12hi = 0,
    },
    s = {
      iflag = 0,
      opcode = 0,
      imm12_0_5 = 0,
      funct3 = 0,
      rs1 = 0,
      rs2 = 0,
      imm12_5_7 = 0,
      --
      imm12 = 0,
      s_imm12 = 0,
    },
    u = {
      iflag = 0,
      opcode = 0,
      rd = 0,
      imm20 = 0,
    },
    b = {
      iflag = 0,
      opcode = 0,
      imm13_11_1 = 0,
      imm13_1_4 = 0,
      funct3 = 0,
      rs1 = 0,
      rs2 = 0,
      imm13_5_6 = 0,
      imm13_12_1 = 0,
      --
      imm13 = 0,
      s_imm13 = 0
    },
    j = {
      iflag = 0,
      opcode = 0,
      rd = 0,
      imm21_12_8 = 0,
      imm21_11_1 = 0,
      imm21_1_10 = 0,
      imm21_20_1 = 0,
      --
      imm21 = 0,
      s_imm21 = 0,
    }
  }
end

function isa.init(oku, assigns)
  init_riscv_assigns(assigns)
end

function isa.reset_sp(oku, assigns)
  -- Reset the stack pointer to the end of memory
  assigns.registers.x[2].u32 = oku.memory:size()
end

function isa.dispose(oku, assigns)
  --
end

function isa.reset(oku, assigns)
  --
end

-- Honestly only usable with the RV32i
function isa.load_elf_binary(oku, assigns, blob)
  local stream = StringBuffer:new(blob)

  local elf_prog = yatm_oku.elf:read(stream)

  elf_prog:reduce_segments(nil, function (segment, _unused)
    if segment.header.type == "PT_LOAD" then
      --print(dump(segment))
      oku:clear_memory_slice(segment.header.vaddr, segment.header.memsz)
      oku:w_memory_blob(segment.header.vaddr, segment.blob)
    end
  end)

  assigns.registers.pc.u32 = elf_prog:get_entry_vaddr()

  return oku
end

function isa.step(oku, assigns)
  oku.exec_counter = oku.exec_counter + 1
  assert(assigns.registers.x[0].i32 == 0, "expected 0 register to be well 0 got:" .. assigns.registers.x[0].i32)

  return isa.step_ins(oku, assigns, oku:get_memory_i32(assigns.registers.pc.u32))
end

function isa.step_ins(oku, assigns, ins)
  isa:load_head(ins, assigns)

  local npc = assigns.registers.pc.u32
  if assigns._native.u32 == 0 then
    return nil, "illegal instruction"
  else
    if assigns._native.head.iflag == 0x3 then
      assigns.registers.pc.u32 = npc + 4
      local ins_name = assert(isa.OPCODE_TO_INS[assigns._native.head.opcode])
      --print(oku.exec_counter .. " | PC:" .. format_hex(8, npc) .. " STEP:" .. ins_name .. "(" .. format_hex(8, assigns._native.u32) .. ")")
      return isa.ins[ins_name](assigns._native, npc, oku, assigns)
    else
      error(oku.exec_counter .. " | PC:" .. format_hex(8, npc) .." Bad instruction " .. format_hex(8, assigns._native.u32))
      -- TODO: error
    end
  end
end

function isa.bindump(oku, assigns, stream)
  local bytes_written = 0
  -- Write Version
  local bw, err = ByteBuf.w_u32(stream, 1)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Write registers
  local bw, err = isa._bindump_registers(oku, assigns, stream)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end
  return bytes_written, nil
end

function isa.binload(oku, assigns, stream)
  local bytes_read = 0
  local version, br = ByteBuf.r_u32(stream)
  bytes_read = bytes_read + br

  init_riscv_assigns(assigns)

  if version == 0 then
    -- nothing to do
  elseif version == 1 then
    -- reload registers
    assigns.registers = ffi.new("struct yatm_oku_registers32")
    bytes_read = bytes_read + isa._binload_registers(oku, assigns, stream)
  else
    error("unexpected riscv binload version " .. version)
  end
  return bytes_read
end

function isa._binload_registers(oku, assigns, stream)
  local bytes_read = 0
  for i = 0,31 do
    local rv, br = ByteBuf.r_i32(stream)
    bytes_read = bytes_read + br
    assigns.registers.x[i].i32 = rv
  end
  assigns.registers.pc.u32 = ByteBuf.r_u32(stream)
  return bytes_read
end

function isa._bindump_registers(oku, assigns, stream)
  local bytes_written = 0

  for i = 0,31 do
    local rv = assigns.registers.x[i].i32
    local bw, err = ByteBuf.w_i32(stream, rv)
    bytes_written = bytes_written + bw

    if err then
      return bytes_written, err
    end
  end

  local bw, err = ByteBuf.w_u32(stream, assigns.registers.pc.u32)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end
  return bytes_written, nil
end

dofile(yatm_oku.modpath .. "/lib/oku/isa/riscv/ffi.lua")
dofile(yatm_oku.modpath .. "/lib/oku/isa/riscv/isa.lua")
dofile(yatm_oku.modpath .. "/lib/oku/isa/riscv/assembler.lua")
