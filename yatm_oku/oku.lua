--[[
Registers:
x0-x31
pc
]]

-- string.rep to initialize the memory
-- string.unpack and string.pack to deserialize and serialize data
yatm_oku.OKU = yatm_core.Class:extends()

dofile(yatm_oku.modpath .. "/lib/oku/memory.lua")

local ffi = assert(yatm_oku.ffi)


ffi.cdef[[
union yatm_oku_register32 {
  int8   i8v[4];
  uint8  u8v[4];
  int16  i16v[2];
  uint16 u16v[2];
  int32  i32v[1];
  uint32 u32v[1];
  float  fv[1];
  int32  i;
  uint32 u;
  float  f;
}

struct yatm_oku_registers {
  yatm_oku_register32 x0;
  yatm_oku_register32 x1;
  yatm_oku_register32 x2;
  yatm_oku_register32 x3;
  yatm_oku_register32 x4;
  yatm_oku_register32 x5;
  yatm_oku_register32 x6;
  yatm_oku_register32 x7;
  yatm_oku_register32 x8;
  yatm_oku_register32 x9;
  yatm_oku_register32 x10;
  yatm_oku_register32 x11;
  yatm_oku_register32 x12;
  yatm_oku_register32 x13;
  yatm_oku_register32 x14;
  yatm_oku_register32 x15;
  yatm_oku_register32 x16;
  yatm_oku_register32 x17;
  yatm_oku_register32 x18;
  yatm_oku_register32 x19;
  yatm_oku_register32 x20;
  yatm_oku_register32 x21;
  yatm_oku_register32 x22;
  yatm_oku_register32 x23;
  yatm_oku_register32 x24;
  yatm_oku_register32 x25;
  yatm_oku_register32 x26;
  yatm_oku_register32 x27;
  yatm_oku_register32 x28;
  yatm_oku_register32 x29;
  yatm_oku_register32 x30;
  yatm_oku_register32 x31;
  uint32 pc;
};
]]

local OKU = yatm_oku.OKU
local m = OKU.instance_class

function m:initialize()
  self.registers = {
    pc = 0,
  }

  for i = 0,31 do
    self.registers["x" .. i] = 0
  end

  --self.memory_size = 0x100000 -- Roughly 1mb
  self.memory_size = 0x40000 -- Roughly 256kb
  self.memory = yatm_oku.OKU.BinaryMemory:new(self.memory_size)
end

function m:step()
end

function m:get_memory_byte(index)
  return self.memory:i8(index)
end

function m:put_memory_byte(index, value)
  return self.memory:w_i8(index, value)
end

function m:get_memory_slice(index, len)
  return self.memory:bytes(index, len)
end

function m:put_memory_slice(index, bytes)
  return self.memory:put_bytes(index, bytes)
end

yatm_oku.OKU = OKU
