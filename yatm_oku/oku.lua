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
  int8_t   i8v[4];
  uint8_t  u8v[4];
  int16_t  i16v[2];
  uint16_t u16v[2];
  int32_t  i32v[1];
  uint32_t u32v[1];
  float  fv[1];
  int32_t  i;
  uint32_t u;
  float  f;
};
]]

ffi.cdef[[
struct yatm_oku_registers32 {
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
  uint32_t pc;
};
]]

ffi.cdef[[
union yatm_oku_rv32i_isa {
  int32_t value;
  struct r {
    int8_t opcode : 7;
    int8_t rd : 5;
    int8_t funct3 : 3;
    int8_t rs1 : 5;
    int8_t rs2 : 5;
    int8_t funct7 : 7;
  };
  struct i {
    int8_t opcode : 7;
    int8_t rd : 5;
    int8_t funct3 : 3;
    int8_t rs1 : 5;
    int16_t imm : 12;
  };
  struct s {
    int8_t opcode : 7;
    int8_t imm0 : 5;
    int8_t funct3 : 3;
    int8_t rs1 : 5;
    int8_t rs2 : 5;
    int8_t imm1 : 7;
  };
  struct u {
    int8_t opcode : 7;
    int8_t rd : 5;
    int32_t imm : 20;
  };
  struct b {
    int8_t opcode : 7;
    int8_t imm0 : 1;
    int8_t imm1 : 4;
    int8_t funct3 : 3;
    int8_t rs1 : 5;
    int8_t rs2 : 5;
    int8_t imm2 : 6;
    int8_t imm3 : 1;
  };
  struct j {
    int8_t opcode : 7;
    int8_t rd : 5;
    union {
      int32_t offset : 20;
      struct {
        int8_t imm0 : 8;
        int8_t imm1 : 1;
        int16_t imm2 : 10;
        int8_t imm3 : 1;
      };
    };
  };
};
]]

local OKU = yatm_oku.OKU
local m = OKU.instance_class

function m:initialize()
  self.registers = ffi.new("yatm_oku_registers32")
  self.memory = yatm_oku.OKU.Memory:new(0x40000 --[[ Roughly 256kb ]])
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
