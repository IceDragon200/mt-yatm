local bit = assert(yatm_oku.bit)
local ffi = assert(yatm_oku.ffi)

local oku_6502 = ffi.load(yatm_oku.modpath .. "/ext/oku_6502.so")
local code_table = {
  [-1] = SEGFAULT_CODE,
  [0] = OK_CODE,
  [1] = INVALID_CODE,
  [4] = HALT_CODE,
  [5] = HANG_CODE,
}

ffi.cdef([[
struct oku_6502_chip
{
  // 64 bit block
  uint16_t pc;        // Program Counter
  uint8_t sp;         // Stack Pointer
  int8_t acc;         // Accumulator
  int8_t x;           // X
  int8_t y;           // Y
  int8_t sr;          // Status Register [NV-BDIZC]
  int8_t _padding;

  uint32_t cycles; // Cycles never go backwards do they?
  int32_t operand; // Any data we need to store for a bit
};

void oku_6502_init(struct oku_6502_chip* chip);
int oku_6502_step(struct oku_6502_chip* chip, int32_t mem_size, char* mem);
]])

local chip = ffi.new("struct oku_6502_chip")
local mem_size = 0xFFFF
local mem = ffi.new("char[?]", mem_size)

oku_6502.oku_6502_init(chip)

local status = oku_6502.oku_6502_step(chip, mem_size, mem);
print("STATUS", status)

local isa = {}

function isa.step(oku)
end

yatm_oku.OKU.isa.MOS6502 = isa