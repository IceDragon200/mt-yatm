local ffi = assert(yatm_oku.ffi)

ffi.cdef([[
struct oku_6502_chip
{
  uint16_t ab;        // Address Bus
  uint16_t pc;        // Program Counter
  uint8_t sp;         // Stack Pointer
  uint8_t ir;         // Instruction Register
  int8_t a;           // Accumulator
  int8_t x;           // X
  int8_t y;           // Y
  int8_t sr;          // Status Register [NV-BDIZC]
  // Ends the 6502 Registers

  // 0000 (state param) 0000 (state code)
  int8_t state; // Not apart of the 6502,
                // this is here to define different states the CPU is in for the step function

  uint32_t cycles; // Cycles never go backwards do they?
  int32_t operand; // Any data we need to store for a bit
};

int oku_6502_chip_size();
void oku_6502_chip_init(struct oku_6502_chip* chip);
int oku_6502_chip_step(struct oku_6502_chip* chip, int32_t mem_size, char* mem);
]])

local oku_6502
pcall(function ()
  oku_6502 = ffi.load(yatm_oku.modpath .. "/ext/oku_6502.so")
end)

if not oku_6502 then
  minetest.log("warning", "oku_6502 shared object is not available, skipping implementation")
  return
end

yatm_oku.OKU.isa.MOS6502.has_native = true

yatm_oku.OKU.isa.MOS6502.NativeChip = foundation.com.Class:extends("yatm_oku.OKU.isa.MOS6502.NativeChip")
local ic = yatm_oku.OKU.isa.MOS6502.NativeChip.instance_class

function ic:initialize(options)
  options = options or {}
  self.m_chip = ffi.new("struct oku_6502_chip")
  oku_6502.oku_6502_chip_init(self.m_chip)
  self.m_mem_size = options.memory_size or 0xFFFF
  self.m_mem = options.memory
  if options.create_memory then
    self.m_mem = ffi.new("uint8_t[?]", mem_size)
  end
end

function ic:needs_memory_reassignment()
  return true
end

function ic:dispose()
  --
end

function ic:step()
  return oku_6502.oku_6502_chip_step(self.m_chip, self.m_mem_size, self.m_mem)
end

--- @spec #set_memory(MemoryBase): self
function ic:set_memory(memory)
  self.m_mem_inst = memory
  self.m_mem_size = self.m_mem_inst:size()
  self.m_mem = self.m_mem_inst:ptr()
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
