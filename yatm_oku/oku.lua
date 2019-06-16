--[[
Registers:
x0-x31
pc
]]

yatm_oku.OKU = yatm_core.Class:extends()
yatm_oku.OKU.isa = {}

dofile(yatm_oku.modpath .. "/lib/oku/memory.lua")

local ffi = assert(yatm_oku.ffi)

ffi.cdef[[
union yatm_oku_register32 {
  int8_t   i8v[4];
  uint8_t  u8v[4];
  int16_t  i16v[2];
  uint16_t u16v[2];
  int32_t  i32v[1];
  uint32_t u32v[1];
  float    fv[1];
  int32_t  i32;
  uint32_t u32;
  float    f32;
};
]]

ffi.cdef[[
struct yatm_oku_registers32 {
  union {
    union yatm_oku_register32 x[32];
    struct {
      union yatm_oku_register32 x0;
      union yatm_oku_register32 x1;
      union yatm_oku_register32 x2;
      union yatm_oku_register32 x3;
      union yatm_oku_register32 x4;
      union yatm_oku_register32 x5;
      union yatm_oku_register32 x6;
      union yatm_oku_register32 x7;
      union yatm_oku_register32 x8;
      union yatm_oku_register32 x9;
      union yatm_oku_register32 x10;
      union yatm_oku_register32 x11;
      union yatm_oku_register32 x12;
      union yatm_oku_register32 x13;
      union yatm_oku_register32 x14;
      union yatm_oku_register32 x15;
      union yatm_oku_register32 x16;
      union yatm_oku_register32 x17;
      union yatm_oku_register32 x18;
      union yatm_oku_register32 x19;
      union yatm_oku_register32 x20;
      union yatm_oku_register32 x21;
      union yatm_oku_register32 x22;
      union yatm_oku_register32 x23;
      union yatm_oku_register32 x24;
      union yatm_oku_register32 x25;
      union yatm_oku_register32 x26;
      union yatm_oku_register32 x27;
      union yatm_oku_register32 x28;
      union yatm_oku_register32 x29;
      union yatm_oku_register32 x30;
      union yatm_oku_register32 x31;
    };
  };
  uint32_t pc;
};
]]

dofile(yatm_oku.modpath .. "/lib/oku/isa/riscv.lua")

local OKU = yatm_oku.OKU
local ic = OKU.instance_class

function ic:initialize(options)
  options.memory_size = options.memory_size or 0x40000
  if options.memory_size < 4 then
    error("requested memory size too small")
  end
  if options.memory_size > 0x40000 then
    error("requested memory size too larger, cannot exceed 1mb")
  end
  -- the registers
  self.registers = ffi.new("yatm_oku_registers32")
  -- utility for decoding instructions
  self.ins = ffi.new("yatm_oku_rv32i_ins")
  -- memory
  self.memory = yatm_oku.OKU.Memory:new(options.memory_size --[[ Roughly 256kb ]])
end

function ic:step()
end

function ic:get_memory_byte(index)
  return self.memory:i8(index)
end

function ic:put_memory_byte(index, value)
  return self.memory:w_i8(index, value)
end

function ic:get_memory_slice(index, len)
  return self.memory:bytes(index, len)
end

function ic:put_memory_slice(index, bytes)
  return self.memory:put_bytes(index, bytes)
end

yatm_oku.OKU = OKU
