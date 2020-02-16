local bit = assert(yatm_oku.bit)
local ffi = assert(yatm_oku.ffi)

local oku_6502
pcall(function ()
  oku_6502 = ffi.load(yatm_oku.modpath .. "/ext/oku_6502.so")
end)

if not oku_6502 then
  minetest.log("warn", "oku_6502 shared object is not available, skipping implementation")
  minetest.log("warn", "\n\nWARN: 6502 based CPUs will not be available.\n\n")
  return
end

local code_table = {
  [0] = OK_CODE,
  [1] = INVALID_CODE,
  [4] = HALT_CODE,
  [5] = HANG_CODE,
  [127] = SEGFAULT_CODE,
}

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

void oku_6502_init(struct oku_6502_chip* chip);
int oku_6502_step(struct oku_6502_chip* chip, int32_t mem_size, char* mem);
]])

local isa = {}

function isa.test()
  local chip = ffi.new("struct oku_6502_chip")
  local mem_size = 0xFFFF
  local mem = ffi.new("uint8_t[?]", mem_size)

  oku_6502.oku_6502_init(chip)

  local status = oku_6502.oku_6502_step(chip, mem_size, mem);
  print("STATUS", status)

  chip = nil
  mem = nil
end

function isa.step(oku)
end

yatm_oku.OKU.isa.MOS6502 = isa
