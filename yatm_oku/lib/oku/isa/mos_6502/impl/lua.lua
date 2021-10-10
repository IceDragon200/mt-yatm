local isa = yatm_oku.OKU.isa.MOS6502

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
  self.m_mem_size = options.memory_size or 0xFFFF
  self.m_mem = {}
end

function ic:dispose()
  --
end

function ic:step()
  local lostate = self.m_chip.state % 0xF
  if lostate == CPU_STATE_RESET then
    return self:_step_startup()
  elseif lostate == CPU_STATE_RUN then
    return self:_step_fex()
  elseif lostate == CPU_STATE_HANG then
    return HANG_CODE
  else
    return INVALID_CODE
  end
end

function ic:set_memory(size, ptr)
  self.m_mem_size = size
  self.m_mem = ptr
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

-- @private
function ic:_step_startup()
  local histate = math.floor(self.m_chip.state / 16)
  local chip = self.m_chip

  if histate == 0 then
    chip.ab = chip.pc
    -- TODO: read memory
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = chip.state + 16
    return STARTUP_CODE

  elseif histate == 1 then
    chip.ab = chip.pc
    -- TODO: read memory
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = chip.state + 16
    return STARTUP_CODE

  elseif histate == 2 then
    chip.ab = chip.pc
    -- TODO: read memory
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = chip.state + 16
    return STARTUP_CODE

  elseif histate == 3 then
    chip.ab = 0xFFFF
    -- TODO: read memory
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = chip.state + 16
    return STARTUP_CODE

  elseif histate == 4 then
    chip.ab = 0x01F7
    -- TODO: read memory
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = chip.state + 16
    return STARTUP_CODE

  elseif histate == 5 then
    chip.ab = 0x01F6
    -- TODO: read memory
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = chip.state + 16
    return STARTUP_CODE

  elseif histate == 6 then
    chip.ab = 0x01F5
    -- TODO: read memory
    chip.pc = 0x00FF
    chip.a = 0xAA
    chip.ir = 0x00
    chip.sr = 0x02
    chip.state = chip.state + 16
    return STARTUP_CODE

  elseif histate == 7 then
    chip.ab = RESET_VECTOR_PTR
    chip.pc = 0 -- TODO: read memory
    chip.state = chip.state + 16
    return STARTUP_CODE

  elseif histate == 8 then
    chip.ab = RESET_VECTOR_PTR + 1
    chip.pc = 0 -- TODO: read memory
    chip.state = CPU_STATE_RUN
    return OK_CODE

  else
    chip.state = CPU_STATE_HANG
    return HANG_CODE
  end
end

-- Fetch and execute
--
-- @private
function ic:_step_fex()
  -- TODO: actually fetch
  return HANG_CODE
end
