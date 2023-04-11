--- @namespace yatm_oku.OKU.isa.MOS6502
local isa = assert(yatm_oku.OKU.isa.MOS6502)

local bit = assert(foundation.com.bit)

--- @class LuaChip
isa.LuaChip = foundation.com.Class:extends("yatm_oku.OKU.isa.MOS6502.LuaChip")
local ic = isa.LuaChip.instance_class

local OK_CODE = isa.OK_CODE
local INVALID_CODE = isa.INVALID_CODE
local HALT_CODE = isa.HALT_CODE
local HANG_CODE = isa.HANG_CODE
local STARTUP_CODE = isa.STARTUP_CODE
local SEGFAULT_CODE = isa.SEGFAULT_CODE

local CPU_STATE_RESET = isa.CPU_STATE_RESET
local CPU_STATE_RUN = isa.CPU_STATE_RUN
local CPU_STATE_HANG = isa.CPU_STATE_HANG

local NMI_VECTOR_PTR = isa.NMI_VECTOR_PTR
local RESET_VECTOR_PTR = isa.RESET_VECTOR_PTR
local IRQ_VECTOR_PTR = isa.IRQ_VECTOR_PTR
local BREAK_VECTOR_PTR = isa.BREAK_VECTOR_PTR

local OPS = {}

--- @spec #initialize(Table): void
function ic:initialize(options)
  options = options or {}

  self.m_chip = {
    ab = 0,
    pc = 0,
    sp = 0xFF,
    ir = 0,
    a = 0,
    x = 0,
    y = 0,
    sr = 0,
    state = CPU_STATE_RESET, -- reset state
    cycles = 0,
    operand = 0,
  }
  self.m_mem = options.memory
end

function ic:dispose()
  --
end

function ic:step()
  local chip = self.m_chip
  local step_state = bit.band(chip.state, 0x0F)
  if step_state == CPU_STATE_RESET then
    return self:_chip_startup()
  elseif step_state == CPU_STATE_RUN then
    return self:_chip_fex()
  elseif step_state == CPU_STATE_HANG then
    return HANG_CODE
  else
    return INVALID_CODE
  end
end

function ic:set_memory(memory)
  self.m_mem = memory
  return self
end

function ic:get_state()
  return self.m_chip.state
end

function ic:set_state(state)
  self.m_chip.state = state
  return self
end

function ic:get_cycles()
  return self.m_chip.cycles
end

function ic:set_cycles(cycles)
  self.m_chip.cycles = cycles
  return self
end

function ic:get_operand()
  return self.m_chip.operand
end

function ic:set_operand(operand)
  self.m_chip.operand = operand
  return self
end

function ic:get_register_ab()
  return self.m_chip.ab
end

function ic:set_register_ab(ab)
  self.m_chip.ab = ab
  return self
end

function ic:get_register_pc()
  return self.m_chip.pc
end

function ic:set_register_pc(pc)
  self.m_chip.pc = pc
  return self
end

function ic:get_register_sp()
  return self.m_chip.sp
end

function ic:set_register_sp(sp)
  self.m_chip.sp = sp
  return self
end

function ic:get_register_ir()
  return self.m_chip.ir
end

function ic:set_register_ir(ir)
  self.m_chip.ir = ir
  return self
end

function ic:get_register_a()
  return self.m_chip.a
end

function ic:set_register_a(a)
  self.m_chip.a = a
  return self
end

function ic:get_register_x()
  return self.m_chip.x
end

function ic:set_register_x(x)
  self.m_chip.x = x
  return self
end

function ic:get_register_y()
  return self.m_chip.y
end

function ic:set_register_y(y)
  self.m_chip.y = y
  return self
end

function ic:get_register_sr()
  return self.m_chip.sr
end

function ic:set_register_sr(sr)
  self.m_chip.sr = sr
  return self
end

local function next_stage(value)
  local hi = bit.band(bit.rshift(value, 4), 0x0F)
  local lo = bit.band(value, 0x0F)

  return bit.lshift(hi + 1, 4) + lo
end

--- @spec #_chip_startup(): Integer
function ic:_chip_startup()
  local chip = self.m_chip
  local startup_stage = bit.band(bit.rshift(chip.state, 4), 0x0F)

  if startup_stage == 0 then
    chip.ab = chip.pc
    self:_chip_read_mem_u8(chip.ab)
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = next_stage(chip.state)
    return STARTUP_CODE

  elseif startup_stage == 1 then
    chip.ab = chip.pc
    self:_chip_read_mem_u8(chip.ab)
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = next_stage(chip.state)
    return STARTUP_CODE

  elseif startup_stage == 2 then
    chip.ab = chip.pc
    self:_chip_read_mem_u8(chip.ab)
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = next_stage(chip.state)
    return STARTUP_CODE

  elseif startup_stage == 3 then
    chip.ab = 0xFFFF
    self:_chip_read_mem_u8(chip.ab)
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = next_stage(chip.state)
    return STARTUP_CODE

  elseif startup_stage == 4 then
    chip.ab = 0x01F7
    self:_chip_read_mem_u8(chip.ab)
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = next_stage(chip.state)
    return STARTUP_CODE

  elseif startup_stage == 5 then
    chip.ab = 0x01F6
    self:_chip_read_mem_u8(chip.ab)
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = next_stage(chip.state)
    return STARTUP_CODE

  elseif startup_stage == 6 then
    chip.ab = 0x01F5
    self:_chip_read_mem_u8(chip.ab)
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = next_stage(chip.state)
    return STARTUP_CODE

  elseif startup_stage == 7 then
    chip.ab = RESET_VECTOR_PTR
    chip.pc = self:_chip_read_mem_u8(chip.ab)
    chip.state = next_stage(chip.state)
    return STARTUP_CODE

  elseif startup_stage == 8 then
    chip.ab = RESET_VECTOR_PTR + 1
    local val = self:_chip_read_mem_u8(chip.ab)
    chip.pc = chip.pc + val * 256
    chip.state = CPU_STATE_RUN
    return OK_CODE

  else
    chip.state = CPU_STATE_HANG
    return HANG_CODE
  end
end

--- Fetch and execute
---
--- @spec #_chip_fex(): Integer
function ic:_chip_fex()
  local status = self:_chip_fetch()
  if status == OK_CODE then
    return self:_chip_exec()
  end

  return status
end

--- @spec #_chip_fetch(): (status: Integer)
function ic:_chip_fetch()
  local status, opcode = self:_chip_read_pc_mem_u8()

  if status == OK_CODE then
    local chip = self.m_chip
    chip.ir = opcode
    chip.pc = chip.pc + 1
  end

  return status
end

--- @spec #_chip_exec(): (status: Integer)
function ic:_chip_exec()
  local chip = self.m_chip
  local op = OPS[chip.ir]
  if op then
    return op(self)
  end
  return HANG_CODE
end

--
-- Memory Operations
--

--- @spec #_read_mem_u8(index: Integer): (status: Integer, byte: Integer)
function ic:_read_mem_u8(index)
  if index < 0 or index >= self.m_mem:size() then
    return SEGFAULT_CODE, nil
  end
  return OK_CODE, self.m_mem:r_u8(index)
end

--- @spec #_write_mem_u8(index: Integer, value: Integer): (status: Integer, byte: Integer)
function ic:_write_mem_u8(index, value)
  if index < 0 or index >= self.m_mem:size() then
    return SEGFAULT_CODE, nil
  end
  self.m_mem:w_u8(index, value)
  return OK_CODE
end

--- @spec #_read_mem_u16(index: Integer): (status: Integer, byte: Integer)
function ic:_read_mem_u16(index)
  local status
  local hi
  local lo

  status, lo = self:_read_mem_u8(index)
  if status ~= OK_CODE then
    return status, 0
  end

  status, hi = self:_read_mem_u8(index)
  if status ~= OK_CODE then
    return status, 0
  end

  return OK_CODE, hi * 256 + lo
end

--- @spec #_read_mem_i16(index: Integer): (status: Integer, byte: Integer)
function ic:_read_mem_i16(index)
  local status, val = self:_read_mem_u16(index)
  if status == OK_CODE then
    if val >= 32768 then
      return status, val - 65536
    end
  end
  return status, val
end

--- @spec #_read_mem_i8(index: Integer): (status: Integer, byte: Integer)
function ic:_read_mem_i8(index)
  if index < 0 or index >= self.m_mem:size() then
    return SEGFAULT_CODE, nil
  end
  return OK_CODE, self.m_mem:r_i8(index)
end

--- @spec #_write_mem_i8(index: Integer, value: Integer): (status: Integer, byte: Integer)
function ic:_write_mem_i8(index, value)
  assert(index, "expected index")
  assert(value, "expected value")
  if index < 0 or index >= self.m_mem:size() then
    return SEGFAULT_CODE, nil
  end
  self.m_mem:w_i8(index, value)
  return OK_CODE
end

--- @spec #_chip_read_mem_u8(index: Integer): (status: Integer, byte: Integer)
function ic:_chip_read_mem_u8(index)
  local chip = self.m_chip
  chip.cycles = chip.cycles + 1
  chip.ab = index

  return self:_read_mem_u8(index)
end

--- @spec #_chip_read_mem_u16(index: Integer): (status: Integer, byte: Integer)
function ic:_chip_read_mem_u16(index)
  local chip = self.m_chip
  chip.cycles = chip.cycles + 2
  chip.ab = index

  return self:_read_mem_u16(index)
end

--- @spec #_chip_write_mem_u8(index: Integer, value: Integer):
function ic:_chip_write_mem_u8(index, value)
  local chip = self.m_chip
  chip.cycles = chip.cycles + 1
  chip.ab = index

  return self:_write_mem_u8(index, value)
end

--- @spec #_chip_read_mem_i8(index: Integer): (status: Integer, byte: Integer)
function ic:_chip_read_mem_i8(index)
  local chip = self.m_chip
  chip.cycles = chip.cycles + 1
  chip.ab = index

  return self:_read_mem_i8(index)
end

--- @spec #_chip_read_mem_i16(index: Integer): (status: Integer, byte: Integer)
function ic:_chip_read_mem_i16(index)
  local chip = self.m_chip
  chip.cycles = chip.cycles + 2
  chip.ab = index

  return self:_read_mem_i16(index)
end

--- @spec #_chip_write_mem_i8(index: Integer, value: Integer):
function ic:_chip_write_mem_i8(index, value)
  local chip = self.m_chip
  chip.cycles = chip.cycles + 1
  chip.ab = index

  return self:_write_mem_i8(index, value)
end

--- @spec #_chip_read_pc_mem_u8(): (status: Integer, byte: Integer)
function ic:_chip_read_pc_mem_u8()
  local chip = self.m_chip
  return self:_chip_read_mem_u8(chip.pc)
end

function ic:_chip_read_pc_mem_u16()
  local chip = self.m_chip
  return self:_chip_read_mem_u16(chip.pc)
end

function ic:_chip_read_pc_mem_i16()
  local chip = self.m_chip
  return self:_chip_read_mem_i16(chip.pc)
end

--- @spec #_chip_write_pc_mem_u8(value: Integer): (status: Integer, byte: Integer)
function ic:_chip_write_pc_mem_u8(value)
  local chip = self.m_chip
  return self:_chip_write_mem_u8(chip.pc, value)
end

--- @spec #_chip_read_pc_mem_i8(): (status: Integer, byte: Integer)
function ic:_chip_read_pc_mem_i8()
  local chip = self.m_chip
  return self:_chip_read_mem_i8(chip.pc)
end

--
-- Stack
--
function ic:_chip_push_stack_u8(value)
  local chip = self.m_chip
  local status = self:_chip_write_mem_u8(chip.sp + 0x100, value)
  if status == OK_CODE then
    chip.sp = chip.sp - 1
  end
  return status
end

function ic:_chip_read_stack_u8()
  local chip = self.m_chip
  return self:_chip_read_mem_u8(chip.sp + 0x100)
end

function ic:_chip_pop_stack_u8()
  local chip = self.m_chip
  chip.sp = chip.sp + 1
  return self:_chip_read_mem_u8(chip.sp + 0x100)
end

function ic:_chip_push_stack_i8(value)
  assert(value, "expected value")
  local chip = self.m_chip
  local status = self:_chip_write_mem_i8(chip.sp + 0x100, value)
  if status == OK_CODE then
    chip.sp = chip.sp - 1
  end
  return status
end

function ic:_chip_read_stack_i8()
  local chip = self.m_chip
  return self:_chip_read_mem_i8(chip.sp + 0x100)
end

function ic:_chip_pop_stack_i8()
  local chip = self.m_chip
  chip.sp = chip.sp + 1
  return self:_chip_read_mem_i8(chip.sp + 0x100)
end

function ic:_chip_push_pc()
  local chip = self.m_chip
  local hi = math.floor(chip.sp / 256)
  local lo = chip.sp % 256

  local status
  status = self:_chip_push_stack_u8(hi)
  if status ~= OK_CODE then
    return status
  end
  status = self:_chip_push_stack_u8(lo)
  return status
end

function ic:_chip_pop_pc()
  local hi
  local lo
  local status

  local chip = self.m_chip

  lo, status = self:_chip_pop_stack_u8()
  if status ~= OK_CODE then
    return status
  end
  hi, status = self:_chip_pop_stack_u8()
  if status ~= OK_CODE then
    return status
  end
  chip.pc = hi * 256 + lo
  return OK_CODE
end

--
-- operands
--
local function opr_implied_i8(self)
  return self:_chip_read_pc_mem_i8()
end

local function opr_immediate_i8(self)
  local chip = self.m_chip
  -- local status, operand = self:_chip_read_pc_mem_i8()
  chip.operand = chip.pc
  chip.pc = chip.pc + 1
  return OK_CODE
end

local function opr_absolute_i16(self)
  local chip = self.m_chip
  chip.operand = self:_chip_read_pc_mem_i16()
  chip.pc = chip.pc + 1 -- lo
  chip.pc = chip.pc + 1 -- hi
  return OK_CODE
end

local function opr_absolute_i16x(self)
  local chip = self.m_chip
  local ol = self:_chip_read_pc_mem_u8()
  chip.pc = chip.pc + 1 -- lo
  local oh = self:_chip_read_pc_mem_u8()
  chip.pc = chip.pc + 1 -- hi

  ol = ol + chip.x
  chip.operand = oh * 256 + ol

  if ol >= 0x100 then
    -- trigger cycle increments for reading additional memory
    self:_chip_read_mem_u8(chip.operand)
  end

  --- mask
  chip.operand = chip.operand % 0x10000
  return OK_CODE
end

local function opr_absolute_i16y(self)
  local chip = self.m_chip
  local ol = self:_chip_read_pc_mem_u8()
  chip.pc = chip.pc + 1 -- lo
  local oh = self:_chip_read_pc_mem_u8()
  chip.pc = chip.pc + 1 -- hi

  oh = oh * 256
  ol = ol + chip.y
  chip.operand = oh + ol

  if ol >= 0x100 then
    -- trigger cycle increments for reading additional memory
    self:_chip_read_mem_u8(chip.operand)
  end

  --- mask
  chip.operand = chip.operand % 0x10000
  return OK_CODE
end

local function opr_indirect_i16(self)
  local chip = self.m_chip
  local al
  local ah
  local status

  status, al = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status, al
  end
  chip.pc = chip.pc + 1 -- lo
  status, ah = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status, ah
  end
  chip.pc = chip.pc + 1 -- hi

  ah = ah * 256

  local a = ah + al

  local ol
  local oh

  status, ol = self:_chip_read_mem_u8(a)
  if status ~= OK_CODE then
    return status, ol
  end
  status, oh = self:_chip_read_mem_u8(a + 1)
  if status ~= OK_CODE then
    return status, oh
  end

  chip.operand = (oh * 256 + ol) % 0x10000

  return OK_CODE
end

local function opr_indirect_i16x(self)
  local chip = self.m_chip
  local status
  local ptr
  status, ptr = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status, ptr
  end
  chip.pc = chip.pc + 1

  ptr = (ptr + chip.x) % 255

  local ol
  local oh

  status, ol = self:_chip_read_mem_u8(a)
  if status ~= OK_CODE then
    return status, ol
  end
  status, oh = self:_chip_read_mem_u8(a + 1)
  if status ~= OK_CODE then
    return status, oh
  end

  chip.operand = (oh * 256 + ol) % 0x10000

  return OK_CODE
end

local function opr_indirect_i16y(self)
  local chip = self.m_chip
  local status
  local ptr
  local ol
  local oh

  status, ptr = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status, ptr
  end
  chip.pc = chip.pc + 1

  status, ol = self:_chip_read_mem_u8(a)
  if status ~= OK_CODE then
    return status, ol
  end
  ol = ol + chip.y

  status, oh = self:_chip_read_mem_u8(a + 1)
  if status ~= OK_CODE then
    return status, oh
  end
  oh = oh * 256
  if ol > 0x100 then
    self:_chip_read_mem_u8(oh + (ol % 256))
  end

  chip.operand = (oh + ol) % 0x10000
  return OK_CODE
end

local function opr_relative_i16(self)
  local chip = self.m_chip
  local status
  local offset

  status, offset = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status, offset
  end
  chip.pc = chip.pc + 1

  chip.operand = (chip.pc + offset) % 0x10000

  return OK_CODE
end

local function opr_zeropage_i16(self)
  local chip = self.m_chip
  local status
  local ptr

  status, ptr = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status, ptr
  end
  chip.pc = chip.pc + 1

  chip.operand = ptr
  return OK_CODE
end

local function opr_zeropage_i16x(self)
  local chip = self.m_chip
  local status
  local ptr

  status, ptr = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status, ptr
  end
  chip.pc = chip.pc + 1

  chip.operand = (ptr + chip.x) % 256
  return OK_CODE
end

local function opr_zeropage_i16y(self)
  local chip = self.m_chip
  local status
  local ptr

  status, ptr = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status, ptr
  end
  chip.pc = chip.pc + 1

  chip.operand = (ptr + chip.y) % 256
  return OK_CODE
end

--
-- instruction execs
--

-- bit table for reference
--  0  1  2  3  4  5  6  7
--  1  2  4  8  16 32 64 128

local CARRY_FLAG_BIT = 1 -- 0
local ZERO_FLAG_BIT = 2 -- 1
local IRQ_DISABLE_FLAG_BIT = 4 -- 2
local DECIMAL_MODE_FLAG_BIT = 8 -- 3
local BREAK_COMMAND_FLAG_BIT = 16 -- 4
-- 5
local OVERFLOW_FLAG_BIT = 64 -- 6
local NEGATIVE_FLAG_BIT = 128 -- 7

local CARRY_FLAG_DISABLE_MASK = 255 - CARRY_FLAG_BIT
local ZERO_FLAG_DISABLE_MASK = 255 - ZERO_FLAG_BIT
local IRQ_DISABLE_FLAG_DISABLE_MASK = 255 - IRQ_DISABLE_FLAG_BIT
local DECIMAL_MODE_FLAG_DISABLE_MASK = 255 - DECIMAL_MODE_FLAG_BIT
local BREAK_COMMAND_FLAG_DISABLE_MASK = 255 - BREAK_COMMAND_FLAG_BIT
local OVERFLOW_FLAG_DISABLE_MASK = 255 - OVERFLOW_FLAG_BIT
local NEGATIVE_FLAG_DISABLE_MASK = 255 - NEGATIVE_FLAG_BIT

local function set_carry_flag(self, value)
  local chip = self.m_chip
  if bit.band(value, 256) == 256 then
    chip.sr = bit.bor(chip.sr, CARRY_FLAG_BIT)
  else
    chip.sr = bit.band(chip.sr, CARRY_FLAG_DISABLE_MASK)
  end
end

local function set_borrow_flag(self, value)
  local chip = self.m_chip
  if bit.band(value, 256) == 256 then
    chip.sr = bit.band(chip.sr, CARRY_FLAG_DISABLE_MASK)
  else
    chip.sr = bit.bor(chip.sr, CARRY_FLAG_BIT)
  end
end

local function set_negative_flag(self, value)
  local chip = self.m_chip
  if value < 0 then
    chip.sr = bit.bor(chip.sr, NEGATIVE_FLAG_BIT)
  else
    chip.sr = bit.band(chip.sr, NEGATIVE_FLAG_DISABLE_MASK)
  end
end

local function set_zero_flag(self, value)
  local chip = self.m_chip
  if value == 0 then
    chip.sr = bit.bor(chip.sr, ZERO_FLAG_BIT)
  else
    chip.sr = bit.band(chip.sr, ZERO_FLAG_DISABLE_MASK)
  end
end

local function exec_adc(self)
  local chip = self.m_chip
  local op1
  local op2
  local status
  local value

  op1 = chip.a
  status, op2 = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end

  -- A + op2 + carry
  value = op1 + op2 + bit.band(chip.sr, CARRY_FLAG_BIT)

  -- check if decimal mode is enabled
  if bit.band(chip.sr, DECIMAL_MODE_BIT) == 0 then
    -- binary mode
    chip.a = bit.band(value, 0xFF)
    -- ((op1 ^ A) & ~(op1 ^ op2) & 0x80) -- >> 7
    local overflow =
      bit.band(
        bit.bxor(op1, chip.a),
        bit.band(-(bit.bxor(op1, op2) + 1), 0x80)
      )

    if bit.band(overflow, 128) == 128 then
      chip.sr = bit.bor(chip.sr, OVERFLOW_FLAG_BIT)
    else
      chip.sr = bit.band(chip.sr, OVERFLOW_FLAG_DISABLE_MASK)
    end

    set_carry_flag(chip, value)
    set_negative_flag(chip, value)
    set_zero_flag(chip, value)
  else
    -- decimal mode
    error("TODO: decimal mode ADC")
  end

  return OK_CODE
end

local function exec_and(self)
  local chip = self.m_chip
  local status
  local op
  status, op = self:_chip_read_mem_i8(chip.operand)

  if status == OK_CODE then
    chip.a = bit.band(chip.a, op)
    set_negative_flag(chip, chip.a)
    set_zero_flag(chip, chip.a)
  end

  return status
end

local function exec_asl(self)
  local chip = self.m_chip
  local status
  local tmp
  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end

  status = self:_chip_write_mem_i8(chip.operand, tmp)
  if status ~= OK_CODE then
    return status
  end

  if tmp < 0 then
    chip.sr = bit.bor(chip.sr, CARRY_FLAG_BIT)
  else
    chip.sr = bit.band(chip.sr, CARRY_FLAG_DISABLE_MASK)
  end

  tmp = bit.lshift(tmp, 1)

  set_negative_flag(chip, tmp)
  set_zero_flag(chip, tmp)

  status = self:_chip_write_mem_i8(chip.operand, tmp)

  return status
end

local function exec_asl_a(self)
  local chip = self.m_chip
  local tmp = bit.lshift(chip.a, 1) % 256

  set_carry_flag(chip, tmp)
  set_negative_flag(chip, tmp)
  set_zero_flag(chip, tmp)
  return OK_CODE
end

local function do_exec_branch(self)
  local chip = self.m_chip
  self:_chip_read_pc_mem_i8()

  if bit.band(chip.pc, 0xFF00) ~= bit.band(chip.operand, 0xFF00) then
    local addr = bit.bor(bit.band(chip.pc, 0xFF00), bit.band(chip.operand, 0xFF))

    self:_chip_read_mem_i8(addr)
  end

  chip.pc = chip.operand
  return OK_CODE
end

local function exec_bcc(self)
  local chip = self.m_chip
  if bit.band(chip.sr, CARRY_FLAG_BIT) == 0 then
    return do_exec_branch(self)
  end
  return OK_CODE
end

local function exec_bcs(self)
  local chip = self.m_chip
  if bit.band(chip.sr, CARRY_FLAG_BIT) == CARRY_FLAG_BIT then
    return do_exec_branch(self)
  end
  return OK_CODE
end

local function exec_beq(self)
  local chip = self.m_chip
  if bit.band(chip.sr, ZERO_FLAG_BIT) == ZERO_FLAG_BIT then
    return do_exec_branch(self)
  end
  return OK_CODE
end

local function exec_bit(self)
  local chip = self.m_chip
  local status
  local tmp

  status, tmp = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status
  end

  if bit.band(tmp, 0x40) == 0 then
    chip.sr = bit.band(chip.sr, OVERFLOW_FLAG_DISABLE_MASK)
  else
    chip.sr = bit.bor(chip.sr, OVERFLOW_FLAG_BIT)
  end

  set_negative_flag(self, tmp)

  if bit.band(tmp, chip.a) == 0 then
    chip.sr = bit.bor(chip.sr, ZERO_FLAG_BIT)
  else
    chip.sr = bit.band(chip.sr, ZERO_FLAG_DISABLE_MASK)
  end

  return OK_CODE
end

local function exec_bmi(self)
  local chip = self.m_chip
  if bit.band(chip.sr, NEGATIVE_FLAG_BIT) == NEGATIVE_FLAG_BIT then
    return do_exec_branch(self)
  end
  return OK_CODE
end

local function exec_bne(self)
  local chip = self.m_chip
  if bit.band(chip.sr, ZERO_FLAG_BIT) == 0 then
    return do_exec_branch(self)
  end
  return OK_CODE
end

local function exec_bpl(self)
  local chip = self.m_chip
  if bit.band(chip.sr, NEGATIVE_FLAG_BIT) == 0 then
    return do_exec_branch(self)
  end
  return OK_CODE
end

local exec_php

local function exec_brk(self)
  local chip = self.m_chip
  self:_chip_read_pc_mem_i8()
  self:_chip_push_pc()
  exec_php(self)

  --- Enable
  chip.sr = bit.bor(chip.sr, 4)
  chip.pc = self:_chip_read_mem_u8(0xFFFE)
  return OK_CODE
end

local function exec_bvc(self)
  local chip = self.m_chip
  if bit.band(chip.sr, OVERFLOW_FLAG_BIT) == 0 then
    return do_exec_branch(self)
  end
  return OK_CODE
end

local function exec_bvs(self)
  local chip = self.m_chip
  if bit.band(chip.sr, OVERFLOW_FLAG_BIT) == OVERFLOW_FLAG_BIT then
    return do_exec_branch(self)
  end
  return OK_CODE
end

local function exec_clc(self)
  local chip = self.m_chip
  chip.sr = bit.band(chip.sr, CARRY_FLAG_DISABLE_MASK)
  return OK_CODE
end

local function exec_cld(self)
  local chip = self.m_chip
  chip.sr = bit.band(chip.sr, DECIMAL_MODE_FLAG_DISABLE_MASK)
  return OK_CODE
end

local function exec_cli(self)
  local chip = self.m_chip
  chip.sr = bit.band(chip.sr, IRQ_DISABLE_FLAG_DISABLE_MASK)
  return OK_CODE
end

local function exec_clv(self)
  local chip = self.m_chip
  chip.sr = bit.band(chip.sr, OVERFLOW_FLAG_DISABLE_MASK)
  return OK_CODE
end

local function exec_cmp(self)
  local chip = self.m_chip
  local status
  local tmp

  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  tmp = chip.a - tmp

  set_borrow_flag(self, tmp)
  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  return OK_CODE
end

local function exec_cpx(self)
  local chip = self.m_chip
  local status
  local tmp

  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  tmp = chip.x - tmp

  set_borrow_flag(self, tmp)
  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  return OK_CODE
end

local function exec_cpy(self)
  local chip = self.m_chip
  local status
  local tmp

  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  tmp = chip.a - tmp

  set_borrow_flag(self, tmp)
  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  return OK_CODE
end

local function exec_dec(self)
  local chip = self.m_chip
  local status
  local tmp

  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  tmp = (tmp - 1) % 256

  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  status = self:_chip_write_mem_i8(chip.operand, tmp)

  return status
end

local function exec_dex(self)
  local chip = self.m_chip

  chip.x = chip.x - 1

  set_negative_flag(self, chip.x)
  set_zero_flag(self, chip.x)

  return OK_CODE
end

local function exec_dey(self)
  local chip = self.m_chip

  chip.y = chip.y - 1

  set_negative_flag(self, chip.y)
  set_zero_flag(self, chip.y)

  return OK_CODE
end

local function exec_eor(self)
  local chip = self.m_chip

  local status
  local tmp

  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  tmp = bit.bxor(tmp)

  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  chip.a = tmp

  return OK_CODE
end

local function exec_inc(self)
  local chip = self.m_chip

  local status
  local tmp

  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  tmp = tmp + 1

  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  status = self:_chip_write_mem_i8(chip.operand, tmp)

  return status
end

local function exec_inx(self)
  local chip = self.m_chip

  chip.x = chip.x + 1

  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  return OK_CODE
end

local function exec_iny(self)
  local chip = self.m_chip

  chip.y = chip.y + 1

  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  return OK_CODE
end

local function exec_jmp(self)
  local chip = self.m_chip

  chip.pc = chip.operand

  return OK_CODE
end

local function exec_jsr(self)
  local chip = self.m_chip
  local status
  local lo
  local hi

  status, lo = self:_chip_read_pc_mem_u8()
  if status ~= OK_CODE then
    return status
  end
  chip.pc = chip.pc + 1

  status = self:_chip_read_mem_u8(chip.sp + 0x100)
  if status ~= OK_CODE then
    return status
  end

  status = self:_chip_push_pc()
  if status ~= OK_CODE then
    return status
  end

  status, hi = self:_chip_read_pc_mem_u8()

  chip.pc = hi * 256 + lo

  return OK_CODE
end

local function exec_lda(self)
  local chip = self.m_chip
  local status
  local value

  status, value = self:_chip_read_mem_u8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  chip.a = value

  set_negative_flag(self, chip.a)
  set_zero_flag(self, chip.a)

  return OK_CODE
end

local function exec_ldx(self)
  local chip = self.m_chip
  local status
  local value

  status, value = self:_chip_read_mem_u8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  chip.x = value

  set_negative_flag(self, chip.x)
  set_zero_flag(self, chip.x)

  return OK_CODE
end

local function exec_ldy(self)
  local chip = self.m_chip
  local status
  local value

  status, value = self:_chip_read_mem_u8(chip.operand)
  if status ~= OK_CODE then
    return status
  end
  chip.y = value

  set_negative_flag(self, chip.y)
  set_zero_flag(self, chip.y)

  return OK_CODE
end

local function exec_lsr(self)
  local chip = self.m_chip
  local status
  local value

  status, value = self:_chip_read_mem_u8(chip.operand)
  if status ~= OK_CODE then
    return status
  end

  if tmp % 2 == 1 then
    chip.sr = bit.bor(chip.sr, CARRY_FLAG_BIT)
  else
    chip.sr = bit.band(chip.sr, CARRY_FLAG_DISABLE_MASK)
  end

  tmp = bit.rshift(tmp, 1)

  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  status = self:_chip_write_mem_u8(chip.operand, tmp)

  return status
end

local function exec_lsr_a(self)
  local chip = self.m_chip

  if chip.a % 2 == 1 then
    chip.sr = bit.bor(chip.sr, CARRY_FLAG_BIT)
  else
    chip.sr = bit.band(chip.sr, CARRY_FLAG_DISABLE_MASK)
  end

  chip.a = bit.rshift(chip.a, 1)

  set_negative_flag(self, chip.a)
  set_zero_flag(self, chip.a)

  return OK_CODE
end

local function exec_nop(_self)
  return OK_CODE
end

local function exec_ora(self)
  local chip = self.m_chip
  local status
  local value

  status, value = self:_chip_read_mem_u8(chip.operand)
  if status ~= OK_CODE then
    return status
  end

  chip.a = bit.bor(chip.a, value)

  set_negative_flag(self, chip.a)
  set_zero_flag(self, chip.a)

  return OK_CODE
end

local function exec_pha(self)
  local chip = self.m_chip
  return self:_chip_push_stack_i8(chip.a)
end

function exec_php(self)
  local chip = self.m_chip
  return self:_chip_push_stack_i8(chip.sr)
end

local function exec_pla(self)
  local chip = self.m_chip
  local status
  local value

  status = self:_chip_read_stack_i8()
  if status ~= OK_CODE then
    return status
  end

  status, value = self:_chip_pop_stack_i8()
  if status ~= OK_CODE then
    return status
  end

  chip.a = value

  set_negative_flag(self, chip.a)
  set_zero_flag(self, chip.a)

  return OK_CODE
end

local function exec_plp(self)
  local chip = self.m_chip
  local status
  local value

  status = self:_chip_read_stack_i8()
  if status ~= OK_CODE then
    return status
  end

  status, value = self:_chip_pop_stack_i8()
  if status ~= OK_CODE then
    return status
  end

  chip.sr = value

  return OK_CODE
end

local function exec_rol(self)
  local chip = self.m_chip
  local status
  local tmp
  local would_carry
  local carry_bit

  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end

  if bit.band(chip.sr, CARRY_FLAG_BIT) == CARRY_FLAG_BIT then
    carry_bit = 1
  else
    carry_bit = 0
  end

  would_carry = tmp < 0

  tmp = bit.bor(bit.lshift(bit.band(tmp, 0xFF), 1), carry_bit)

  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  status = self:_chip_write_mem_i8(chip.operand, tmp)

  return status
end

local function exec_rol_a(self)
  local chip = self.m_chip
  local carry_bit
  if bit.band(chip.sr, CARRY_FLAG_BIT) == CARRY_FLAG_BIT then
    carry_bit = 1
  else
    carry_bit = 0
  end
  local tmp = bit.bor(bit.lshift(chip.a, 1), carry_bit)

  tmp = bit.band(tmp, 0xFF)

  set_carry_flag(self, tmp)
  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  return OK_CODE
end

local function exec_ror(self)
  local chip = self.m_chip
  local status
  local tmp

  status, tmp = self:_chip_read_mem_i8(chip.operand)
  if status ~= OK_CODE then
    return status
  end

  status = self:_chip_write_mem_i8(chip.operand, tmp)

  local would_carry = tmp % 2 == 1

  local carry_bit = bit.lshift(bit.band(chip.sr, CARRY_FLAG_BIT), 7)

  tmp = bit.bor(bit.rshift(tmp, 1), carry_bit)

  if would_carry then
    chip.sr = bit.bor(chip.sr, CARRY_FLAG_BIT)
  else
    chip.sr = bit.band(chip.sr, CARRY_FLAG_DISABLE_MASK)
  end

  set_negative_flag(self, tmp)
  set_zero_flag(self, tmp)

  status = self:_chip_write_mem_i8(chip.operand, tmp)

  return status
end

local function exec_ror_a(self)
  local chip = self.m_chip
  local status
  local value

  value = chip.a
  if bit.band(chip.sr, CARRY_FLAG_BIT) == CARRY_FLAG_BIT then
    --- set high byte to 1
    value = value + 256
  end

  if bit.band(chip.a, 0x01) == 0x01 then
    chip.sr = bit.bor(chip.a, CARRY_FLAG_BIT)
  else
    chip.sr = bit.band(chip.a, CARRY_FLAG_DISABLE_MASK)
  end

  chip.a = bit.rshift(chip.a, 1)

  set_negative_flag(self, chip.a)
  set_zero_flag(self, chip.a)

  return OK_CODE
end

local function exec_rti(self)
  local chip = self.m_chip
  local status

  status = self:_chip_read_stack_i8()
  if status ~= OK_CODE then
    return status
  end

  status = exec_plp(self)
  if status ~= OK_CODE then
    return status
  end

  status = self:_chip_pop_pc()

  return status
end

local function exec_rts(self)
  local chip = self.m_chip
  local status

  status = self:_chip_read_stack_i8()
  if status ~= OK_CODE then
    return status
  end

  status = self:_chip_pop_pc()
  if status ~= OK_CODE then
    return status
  end

  status = self:_chip_read_pc_mem_i8()

  return status
end

local function exec_sbc(self)
  local chip = self.m_chip
  local op1
  local op2
  local status
  local value

  op1 = chip.a
  status, op2 = self:_chip_read_mem_i8(chip.operand)
  value = op1 - op2 - bit.band(bit.bxor(bit.band(chip.sr, CARRY_FLAG_BIT), 0x01), 0x01)

  -- check if decimal mode is enabled
  if bit.band(chip.sr, DECIMAL_MODE_BIT) == 0 then
    -- binary mode
    chip.a = bit.band(value, 0xFF)
    -- ((op1 ^ op2) & ~(op1 ^ A) & 0x80) -- >> 7
    local overflow = bit.band(bit.bxor(op1, op2), bit.band(bit.bxor(op1, chip.a), 0x80))

    if bit.band(overflow, 0x80) == 0x80 then
      chip.sr = bit.bor(chip.sr, OVERFLOW_FLAG_BIT)
    else
      chip.sr = bit.band(chip.sr, OVERFLOW_FLAG_DISABLE_MASK)
    end

    set_carry_flag(chip, value)
    set_negative_flag(chip, value)
    set_zero_flag(chip, value)
  else
    -- decimal mode
    error("TODO: decimal mode ADC")
  end

  return OK_CODE
end

local function exec_sec(self)
  local chip = self.m_chip

  chip.sr = bit.bor(chip.sr, CARRY_FLAG_BIT)

  return OK_CODE
end

local function exec_sed(self)
  local chip = self.m_chip

  chip.sr = bit.bor(chip.sr, DECIMAL_MODE_FLAG_BIT)

  return OK_CODE
end

local function exec_sei(self)
  local chip = self.m_chip

  chip.sr = bit.bor(chip.sr, IRQ_DISABLE_FLAG_BIT)

  return OK_CODE
end

local function exec_sta(self)
  local chip = self.m_chip

  return self:_chip_write_mem_i8(chip.operand, chip.a)
end

local function exec_stx(self)
  local chip = self.m_chip

  return self:_chip_write_mem_i8(chip.operand, chip.x)
end

local function exec_sty(self)
  local chip = self.m_chip

  return self:_chip_write_mem_i8(chip.operand, chip.y)
end

local function exec_tax(self)
  local chip = self.m_chip

  chip.x = chip.a

  set_negative_flag(self, chip.x)
  set_zero_flag(self, chip.x)

  return OK_CODE
end

local function exec_tay(self)
  local chip = self.m_chip

  chip.x = chip.a

  set_negative_flag(self, chip.x)
  set_zero_flag(self, chip.x)

  return OK_CODE
end

local function exec_tsx(self)
  local chip = self.m_chip

  chip.x = chip.sp

  set_negative_flag(self, chip.x)
  set_zero_flag(self, chip.x)

  return OK_CODE
end

local function exec_txa(self)
  local chip = self.m_chip

  chip.a = chip.x

  set_negative_flag(self, chip.a)
  set_zero_flag(self, chip.a)

  return OK_CODE
end

local function exec_txs(self)
  local chip = self.m_chip

  chip.sp = chip.x

  return OK_CODE
end

local function exec_tya(self)
  local chip = self.m_chip

  chip.a = chip.y

  set_negative_flag(self, chip.a)
  set_zero_flag(self, chip.a)

  return OK_CODE
end

--
-- OPcodeS
--

--- BRK impl
OPS[0x00] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_brk(self)
  end
  return status
end

--- ORA X, ind
OPS[0x01] = function (self)
  local status = opr_indirect_i16x(self)
  if status == OK_CODE then
    return exec_ora(self)
  end
  return status
end

--- 0x02
--- 0x03
--- 0x04

--- ORA zpg
OPS[0x05] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_ora(self)
  end
  return status
end

--- ASL zpg
OPS[0x06] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_asl(self)
  end
  return status
end

--- 0x07

--- PHP impl
OPS[0x08] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_php(self)
  end
  return status
end

--- ORA #
OPS[0x09] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_ora(self)
  end
  return status
end

--- ASL A
OPS[0x0A] = function (self)
  return exec_asl_a(self)
end

--- 0x0B
--- 0x0C

--- ORA abs
OPS[0x0D] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_ora(self)
  end
  return status
end

--- ASL abs
OPS[0x0E] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_asl(self)
  end
  return status
end

--- 0x0F

--- BPL rel
OPS[0x10] = function (self)
  local status = opr_relative_i16(self)
  if status == OK_CODE then
    return exec_bpl(self)
  end
  return status
end

--- ORA ind,Y
OPS[0x11] = function (self)
  local status = opr_indirect_i16y(self)
  if status == OK_CODE then
    return exec_ora(self)
  end
  return status
end

--- 0x12
--- 0x13
--- 0x14

--- ORA zpg,X
OPS[0x15] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_ora(self)
  end
  return status
end

--- ASL zpg,X
OPS[0x16] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_asl(self)
  end
  return status
end

--- 0x17

--- CLC impl
OPS[0x18] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_clc(self)
  end
  return status
end

--- ORA abs,Y
OPS[0x19] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_ora(self)
  end
  return status
end

--- 0x1A
--- 0x1B
--- 0x1C

--- ORA abs,X
OPS[0x1D] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_ora(self)
  end
  return status
end

--- ASL abs,X
OPS[0x1E] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_asl(self)
  end
  return status
end

--- 0x1F

--- JSR abs
OPS[0x20] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_jsr(self)
  end
  return status
end

--- AND X,ind
OPS[0x21] = function (self)
  local status = opr_indirect_i16x(self)
  if status == OK_CODE then
    return exec_and(self)
  end
  return status
end

--- 0x22
--- 0x23

--- BIT zpg
OPS[0x24] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_bit(self)
  end
  return status
end

--- AND zpg
OPS[0x25] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_and(self)
  end
  return status
end

--- ROL zpg
OPS[0x26] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_rol(self)
  end
  return status
end

--- 0x27

--- PLP impl
OPS[0x28] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_plp(self)
  end
  return status
end

--- AND #
OPS[0x29] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_and(self)
  end
  return status
end

--- ROL A
OPS[0x2A] = function (self)
  return exec_rol_a(self)
end

--- 0x2B

--- BIT abs
OPS[0x2C] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_bit(self)
  end
  return status
end

--- AND abs
OPS[0x2D] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_and(self)
  end
  return status
end

--- ROL abs
OPS[0x2E] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_rol(self)
  end
  return status
end

--- 0x2F

--- BMI rel
OPS[0x30] = function (self)
  local status = opr_relative_i16(self)
  if status == OK_CODE then
    return exec_bmi(self)
  end
  return status
end

--- AND ind,Y
OPS[0x31] = function (self)
  local status = opr_relative_i16y(self)
  if status == OK_CODE then
    return exec_and(self)
  end
  return status
end

--- 0x32
--- 0x33
--- 0x34

--- AND zpg,X
OPS[0x35] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_and(self)
  end
  return status
end

--- ROL zpg,X
OPS[0x36] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_rol(self)
  end
  return status
end

--- 0x37

--- SEC impl
OPS[0x38] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_sec(self)
  end
  return status
end

--- AND abs,Y
OPS[0x39] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_and(self)
  end
  return status
end

--- 0x3A
--- 0x3B
--- 0x3C

--- AND abs,X
OPS[0x3D] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_and(self)
  end
  return status
end

--- ROL abs,X
OPS[0x3E] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_rol(self)
  end
  return status
end

--- 0x3F

--- RTI impl
OPS[0x40] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_rti(self)
  end
  return status
end

--- EOR X,ind
OPS[0x41] = function (self)
  local status = opr_indirect_i16x(self)
  if status == OK_CODE then
    return exec_eor(self)
  end
  return status
end

--- 0x42
--- 0x43
--- 0x44

--- EOR zpg
OPS[0x45] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_eor(self)
  end
  return status
end

--- LSR zpg
OPS[0x46] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_lsr(self)
  end
  return status
end

--- 0x47

--- PHA impl
OPS[0x48] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_pha(self)
  end
  return status
end

--- EOR #
OPS[0x49] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_eor(self)
  end
  return status
end

--- LSR A
OPS[0x4A] = function (self)
  return exec_lsr_a(self)
end

--- 0x4B

--- JMP abs
OPS[0x4C] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_jmp(self)
  end
  return status
end

--- EOR abs
OPS[0x4D] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_eor(self)
  end
  return status
end

--- LSR abs
OPS[0x4E] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_lsr(self)
  end
  return status
end

--- 0x4F

--- BVC rel
OPS[0x50] = function (self)
  local status = opr_relative_i16(self)
  if status == OK_CODE then
    return exec_bvc(self)
  end
  return status
end

--- EOR ind,Y
OPS[0x51] = function (self)
  local status = opr_indirect_i16y(self)
  if status == OK_CODE then
    return exec_eor(self)
  end
  return status
end

--- 0x52
--- 0x53
--- 0x54

--- EOR zpg,X
OPS[0x55] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_eor(self)
  end
  return status
end

--- LSR zpg,X
OPS[0x56] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_lsr(self)
  end
  return status
end

--- 0x57

--- CLI impl
OPS[0x58] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_cli(self)
  end
  return status
end

--- EOR abs,Y
OPS[0x59] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_eor(self)
  end
  return status
end

--- 0x5A
--- 0x5B
--- 0x5C

--- EOR abs,X
OPS[0x5D] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_eor(self)
  end
  return status
end

--- LSR abs,X
OPS[0x5E] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_lsr(self)
  end
  return status
end

--- 0x5F

--- RTS impl
OPS[0x60] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_rts(self)
  end
  return status
end

--- ADC X,ind
OPS[0x61] = function (self)
  local status = opr_indirect_i16x(self)
  if status == OK_CODE then
    return exec_adc(self)
  end
  return status
end

--- 0x62
--- 0x63
--- 0x64

--- ADC zpg
OPS[0x65] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_adc(self)
  end
  return status
end

--- ROR zpg
OPS[0x66] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_ror(self)
  end
  return status
end

--- 0x67

--- PLA impl
OPS[0x68] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_pla(self)
  end
  return status
end

--- ADC #
OPS[0x69] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_adc(self)
  end
  return status
end

--- ROR A
OPS[0x6A] = function (self)
  return exec_ror_a(self)
end

--- 0x6B

--- JMP ind
OPS[0x6C] = function (self)
  local status = opr_indirect_i16(self)
  if status == OK_CODE then
    return exec_jmp(self)
  end
  return status
end

--- ADC abs
OPS[0x6D] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_adc(self)
  end
  return status
end

--- ROR abs
OPS[0x6E] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_ror(self)
  end
  return status
end

--- 0x6F

--- BVS rel
OPS[0x70] = function (self)
  local status = opr_relative_i16(self)
  if status == OK_CODE then
    return exec_bvs(self)
  end
  return status
end

--- ADC ind,Y
OPS[0x71] = function (self)
  local status = opr_indirect_i16y(self)
  if status == OK_CODE then
    return exec_adc(self)
  end
  return status
end

--- 0x72
--- 0x73
--- 0x74

--- ADC zpg,X
OPS[0x75] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_adc(self)
  end
  return status
end

--- ROR zpg,X
OPS[0x76] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_ror(self)
  end
  return status
end

--- 0x77

--- SEI impl
OPS[0x78] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_sei(self)
  end
  return status
end

--- ADC abs,Y
OPS[0x79] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_adc(self)
  end
  return status
end

--- 0x7A
--- 0x7B
--- 0x7C

--- ADC abs,X
OPS[0x7D] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_adc(self)
  end
  return status
end

--- ROR abs,X
OPS[0x7E] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_ror(self)
  end
  return status
end

--- 0x7F
--- 0x80

--- STA X,ind
OPS[0x81] = function (self)
  local status = opr_indirect_i16x(self)
  if status == OK_CODE then
    return exec_sta(self)
  end
  return status
end

--- 0x82
--- 0x83

--- STY zpg
OPS[0x84] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_sty(self)
  end
  return status
end

--- STA zpg
OPS[0x85] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_sta(self)
  end
  return status
end

--- STX zpg
OPS[0x86] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_stx(self)
  end
  return status
end

--- 0x87

--- DEY impl
OPS[0x88] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_dey(self)
  end
  return status
end

--- 0x89

--- TXA impl
OPS[0x8A] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_txa(self)
  end
  return status
end

--- 0x8B

--- STY abs
OPS[0x8C] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_sty(self)
  end
  return status
end

--- STA abs
OPS[0x8D] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_sta(self)
  end
  return status
end

--- STX abs
OPS[0x8E] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_stx(self)
  end
  return status
end

--- 0x8F

--- BCC rel
OPS[0x90] = function (self)
  local status = opr_relative_i16(self)
  if status == OK_CODE then
    return exec_bcc(self)
  end
  return status
end

--- STA ind,Y
OPS[0x91] = function (self)
  local status = opr_indirect_i16y(self)
  if status == OK_CODE then
    return exec_sta(self)
  end
  return status
end

--- 0x92
--- 0x93

--- STY zpg,X
OPS[0x94] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_sty(self)
  end
  return status
end

--- STA zpg,X
OPS[0x95] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_sta(self)
  end
  return status
end

--- STX zpg,X
OPS[0x96] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_stx(self)
  end
  return status
end

--- 0x97

--- TYA impl
OPS[0x98] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_tya(self)
  end
  return status
end

--- STA abs,Y
OPS[0x99] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_sta(self)
  end
  return status
end

--- TXS impl
OPS[0x9A] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_txs(self)
  end
  return status
end

--- 0x9B
--- 0x9C

--- STA abs,X
OPS[0x9D] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_sta(self)
  end
  return status
end

--- 0x9E
--- 0x9F

--- LDY #
OPS[0xA0] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_ldy(self)
  end
  return status
end

--- LDA X,ind
OPS[0xA1] = function (self)
  local status = opr_indirect_i16x(self)
  if status == OK_CODE then
    return exec_lda(self)
  end
  return status
end

--- LDX #
OPS[0xA2] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_ldx(self)
  end
  return status
end

--- 0xA3

--- LDY zpg
OPS[0xA4] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_ldy(self)
  end
  return status
end

--- LDA zpg
OPS[0xA5] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_lda(self)
  end
  return status
end

--- LDX zpg
OPS[0xA6] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_ldx(self)
  end
  return status
end

--- 0xA7

--- TAY impl
OPS[0xA8] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_tay(self)
  end
  return status
end

--- LDA #
OPS[0xA9] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_lda(self)
  end
  return status
end

--- TAX impl
OPS[0xAA] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_tax(self)
  end
  return status
end

--- 0xAB

--- LDY abs
OPS[0xAC] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_ldy(self)
  end
  return status
end

--- LDA abs
OPS[0xAD] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_lda(self)
  end
  return status
end

--- LDX abs
OPS[0xAE] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_ldx(self)
  end
  return status
end

--- 0xAF

--- BCS rel
OPS[0xB0] = function (self)
  local status = opr_relative_i16(self)
  if status == OK_CODE then
    return exec_bcs(self)
  end
  return status
end

--- LDA ind,Y
OPS[0xB1] = function (self)
  local status = opr_indirect_i16y(self)
  if status == OK_CODE then
    return exec_lda(self)
  end
  return status
end

--- 0xB2
--- 0xB3

--- LDY zpg,X
OPS[0xB4] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_ldy(self)
  end
  return status
end

--- LDA zpg,X
OPS[0xB5] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_lda(self)
  end
  return status
end

--- LDX zpg,Y
OPS[0xB6] = function (self)
  local status = opr_zeropage_i16y(self)
  if status == OK_CODE then
    return exec_ldx(self)
  end
  return status
end

--- 0xB7

--- CLV impl
OPS[0xB8] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_clv(self)
  end
  return status
end

--- LDA abs,Y
OPS[0xB9] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_lda(self)
  end
  return status
end

--- TSX impl
OPS[0xBA] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_tsx(self)
  end
  return status
end

--- 0xBB

--- LDY abs,X
OPS[0xBC] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_ldy(self)
  end
  return status
end

--- LDA abs,X
OPS[0xBD] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_lda(self)
  end
  return status
end

--- LDX abs,Y
OPS[0xBE] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_ldx(self)
  end
  return status
end

--- 0xBF

--- CPY #
OPS[0xC0] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_cpy(self)
  end
  return status
end

--- CMP X,ind
OPS[0xC1] = function (self)
  local status = opr_indirect_i16x(self)
  if status == OK_CODE then
    return exec_cmp(self)
  end
  return status
end

--- 0xC2
--- 0xC3

--- CPY zpg
OPS[0xC4] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_cpy(self)
  end
  return status
end

--- CMP zpg
OPS[0xC5] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_cmp(self)
  end
  return status
end

--- DEC zpg
OPS[0xC6] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_dec(self)
  end
  return status
end

--- 0xC7

--- INY impl
OPS[0xC8] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_iny(self)
  end
  return status
end

--- CMP #
OPS[0xC9] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_cmp(self)
  end
  return status
end

--- DEX impl
OPS[0xCA] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_dex(self)
  end
  return status
end

--- 0xCB

--- CPY abs
OPS[0xCC] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_cpy(self)
  end
  return status
end

--- CMP abs
OPS[0xCD] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_cmp(self)
  end
  return status
end

--- DEC abs
OPS[0xCE] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_dec(self)
  end
  return status
end

--- 0xCF

--- BNE rel
OPS[0xD0] = function (self)
  local status = opr_relative_i16(self)
  if status == OK_CODE then
    return exec_bne(self)
  end
  return status
end

--- CMP ind,Y
OPS[0xD1] = function (self)
  local status = opr_indirect_i16y(self)
  if status == OK_CODE then
    return exec_cmp(self)
  end
  return status
end

--- 0xD2
--- 0xD3
--- 0xD4

--- CMP zpg,X
OPS[0xD5] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_cmp(self)
  end
  return status
end

--- DEC zpg,X
OPS[0xD6] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_dec(self)
  end
  return status
end

--- 0xD7

--- CLD impl
OPS[0xD8] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_cld(self)
  end
  return status
end

--- CMP abs,Y
OPS[0xD8] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_cmp(self)
  end
  return status
end

--- 0xDA
--- 0xDB
--- 0xDC

--- CMP abs,X
OPS[0xDD] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_cmp(self)
  end
  return status
end

--- DEC abs,X
OPS[0xDE] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_dec(self)
  end
  return status
end

--- 0xDF

--- CPX #
OPS[0xE0] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_cpx(self)
  end
  return status
end

--- SBC X,ind
OPS[0xE1] = function (self)
  local status = opr_indirect_i16x(self)
  if status == OK_CODE then
    return exec_sbc(self)
  end
  return status
end

--- 0xE2
--- 0xE3

--- CPX zpg
OPS[0xE4] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_cpx(self)
  end
  return status
end

--- SBC zpg
OPS[0xE5] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_sbc(self)
  end
  return status
end

--- INC zpg
OPS[0xE6] = function (self)
  local status = opr_zeropage_i16(self)
  if status == OK_CODE then
    return exec_inc(self)
  end
  return status
end

--- 0xE7

--- INX impl
OPS[0xE8] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_inx(self)
  end
  return status
end

--- SBC #
OPS[0xE9] = function (self)
  local status = opr_immediate_i8(self)
  if status == OK_CODE then
    return exec_sbc(self)
  end
  return status
end

--- NOP impl
OPS[0xEA] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_nop(self)
  end
  return status
end

--- 0xEB

--- CPX abs
OPS[0xEC] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_cpx(self)
  end
  return status
end

--- SBC abs
OPS[0xED] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_sbc(self)
  end
  return status
end

--- INC abs
OPS[0xEE] = function (self)
  local status = opr_absolute_i16(self)
  if status == OK_CODE then
    return exec_inc(self)
  end
  return status
end

--- 0xEF

--- BEQ rel
OPS[0xF0] = function (self)
  local status = opr_relative_i16(self)
  if status == OK_CODE then
    return exec_beq(self)
  end
  return status
end

--- SBC ind,Y
OPS[0xF1] = function (self)
  local status = opr_indirect_i16y(self)
  if status == OK_CODE then
    return exec_sbc(self)
  end
  return status
end

--- 0xF2
--- 0xF3
--- 0xF4

--- SBC zpg,X
OPS[0xF5] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_sbc(self)
  end
  return status
end

--- INC zpg,X
OPS[0xF6] = function (self)
  local status = opr_zeropage_i16x(self)
  if status == OK_CODE then
    return exec_inc(self)
  end
  return status
end

--- 0xF7

--- SED impl
OPS[0xF8] = function (self)
  local status = opr_implied_i8(self)
  if status == OK_CODE then
    return exec_sed(self)
  end
  return status
end

--- SBC abs,Y
OPS[0xF9] = function (self)
  local status = opr_absolute_i16y(self)
  if status == OK_CODE then
    return exec_sbc(self)
  end
  return status
end

--- 0xFA
--- 0xFB
--- 0xFC

--- SBC abs,X
OPS[0xFD] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_sbc(self)
  end
  return status
end

--- INC abs,X
OPS[0xFD] = function (self)
  local status = opr_absolute_i16x(self)
  if status == OK_CODE then
    return exec_inc(self)
  end
  return status
end

--- 0xFF
