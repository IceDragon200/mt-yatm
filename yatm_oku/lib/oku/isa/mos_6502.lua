local bit = assert(yatm_oku.bit)
local ffi = assert(yatm_oku.ffi)

local oku_6502
pcall(function ()
  oku_6502 = ffi.load(yatm_oku.modpath .. "/ext/oku_6502.so")
end)

if not oku_6502 then
  minetest.log("warning", "oku_6502 shared object is not available, skipping implementation")
  minetest.log("warning", "\n\nWARN: 6502 based CPUs will not be available.\n\n")
  return
end

local code_table = {
  [0] = "ok",
  [1] = "invalid",
  [4] = "halt",
  [5] = "hang",
  [7] = "startup",
  [127] = "segfault",
}

local CPU_STATE_RESET = 1
local CPU_STATE_RUN = 2
local CPU_STATE_HANG = 3

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

int8_t oku_6502_mem_read_i8(int32_t mem_size, char* mem, int32_t index, int* status);
void oku_6502_mem_write_i8(int32_t mem_size, char* mem, int32_t index, int8_t value, int* status);

int16_t oku_6502_mem_read_i16(int32_t mem_size, char* mem, int32_t index, int* status);

int8_t oku_6502_chip_read_mem_i8(struct oku_6502_chip* chip, int32_t index, int32_t mem_size, char* mem, int* status);
void oku_6502_chip_write_mem_i8(struct oku_6502_chip* chip, int32_t index, int8_t value, int32_t mem_size, char* mem, int* status);

int8_t oku_6502_read_pc_mem_i8(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status);
void oku_6502_write_pc_mem_i8(struct oku_6502_chip* chip, int8_t value, int32_t mem_size, char* mem, int* status);
int16_t oku_6502_read_pc_mem_i16(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status);

void oku_6502_push_stack(struct oku_6502_chip* chip, int8_t value, int32_t mem_size, char* mem, int* status);
int8_t oku_6502_read_stack(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status);
int8_t oku_6502_pop_stack(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status);

void oku_6502_push_pc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status);
void oku_6502_pop_pc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status);

int oku_6502_chip_size();

void oku_6502_chip_init(struct oku_6502_chip* chip);

int oku_6502_chip_exec(struct oku_6502_chip* chip, int32_t mem_size, char* mem);
int oku_6502_chip_fetch(struct oku_6502_chip* chip, int32_t mem_size, char* mem);
int oku_6502_chip_fex(struct oku_6502_chip* chip, int32_t mem_size, char* mem);
int oku_6502_chip_startup(struct oku_6502_chip* chip, int32_t mem_size, char* mem);

int oku_6502_chip_step(struct oku_6502_chip* chip, int32_t mem_size, char* mem);
]])

local isa = {}

function isa.test()
  local chip = ffi.new("struct oku_6502_chip")
  local mem_size = 0xFFFF
  local mem = ffi.new("uint8_t[?]", mem_size)

  oku_6502.oku_6502_chip_init(chip)

  local status = oku_6502.oku_6502_step(chip, mem_size, mem);
  print("STATUS", status)

  chip = nil
  mem = nil
end

function isa.init(oku, assigns)
  local chip = ffi.new("struct oku_6502_chip")
  oku_6502.oku_6502_chip_init(chip)
  assigns.chip = chip
end

function isa.dispose(oku, assigns)
  assigns.chip = nil
end

function isa.reset(oku, assigns)
  assigns.chip.state = CPU_STATE_RESET
end

function isa.step(oku, assigns)
  local mem_size = oku.memory:size()
  local mem_ptr = oku.memory:ptr()

  local code = oku_6502.oku_6502_chip_step(assigns.chip, mem_size, mem_ptr)

  if code_table[code] == "ok" or
     code_table[code] == "startup" then
    return true, nil
  else
    return false, code_table[code]
  end
end

function isa.bindump(oku, stream, assigns)
  local bytes_written = 0
  local bw, err = ByteBuf.w_u32(stream, 1)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Address Bus
  local bw, err = ByteBuf.w_u16(stream, assigns.chip.ab)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Program Counter
  local bw, err = ByteBuf.w_u16(stream, assigns.chip.pc)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Stack Pointer
  local bw, err = ByteBuf.w_u8(stream, assigns.chip.sp)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Instruction Register
  local bw, err = ByteBuf.w_u8(stream, assigns.chip.ir)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- A
  local bw, err = ByteBuf.w_i8(stream, assigns.chip.a)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- X
  local bw, err = ByteBuf.w_i8(stream, assigns.chip.x)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Y
  local bw, err = ByteBuf.w_i8(stream, assigns.chip.y)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- SR
  local bw, err = ByteBuf.w_i8(stream, assigns.chip.sr)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- State
  local bw, err = ByteBuf.w_i8(stream, assigns.chip.state)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Cycles
  local bw, err = ByteBuf.w_u32(stream, assigns.chip.cycles)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Operand
  local bw, err = ByteBuf.w_i32(stream, assigns.chip.operand)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  return bytes_written, nil
end

function isa.binload(oku, stream, assigns)
  local bytes_read = 0
  local version, br = ByteBuf.r_u32(stream)
  bytes_read = bytes_read + br

  if version == 1 then
    local ab, br = ByteBuf.r_u16(stream)
    local pc, br = ByteBuf.r_u16(stream)
    local sp, br = ByteBuf.r_u8(stream)
    local ir, br = ByteBuf.r_u8(stream)
    local a, br = ByteBuf.r_i8(stream)
    local x, br = ByteBuf.r_i8(stream)
    local y, br = ByteBuf.r_i8(stream)
    local sr, br = ByteBuf.r_i8(stream)
    local state, br = ByteBuf.r_i8(stream)
    local cycles, br = ByteBuf.r_u32(stream)
    local operand, br = ByteBuf.r_i32(stream)

    assigns.chip.ab = ab
    assigns.chip.pc = pc
    assigns.chip.sp = sp
    assigns.chip.ir = ir
    assigns.chip.a = a
    assigns.chip.x = x
    assigns.chip.y = y
    assigns.chip.sr = sr
    assigns.chip.state = state
    assigns.chip.cycles = cycles
    assigns.chip.operand = operand
  else
    error("unexpected version=" .. version)
  end
  return bytes_read
end

yatm_oku.OKU.isa.MOS6502 = isa

dofile(yatm_oku.modpath .. "/lib/oku/isa/mos_6502/builder.lua")
