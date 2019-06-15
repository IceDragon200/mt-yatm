--
-- The OKU ISA is an overly simplified instruction set
--
-- It uses a structure similar to RISC-V, just a bit simplified to avoid headaches.
local ISA = {}

-- So first up, it's a purely integer cpu, no floats.
--
-- rd - register destination
-- rs - register source
-- ro - register as operand
-- imm - immediate value (i.e. an integer)
-- P - port number
--
-- Instructions:
-- -- Arithmetic
--   add rd, rs, ro
--   addi rd, rs, imm
--   sub rd, rs, ro
--   subi rd, rs, imm
--   mul rd, rs, ro
--   muli rd, rs, imm
--   div rd, rs, ro
--   divi rd, rs, imm
--   rem rd, rs, ro
--   remi rd, rs, imm
--   xor rd, rs, ro
--   xori rd, rs, imm
--   or rd, rs, ro
--   ori rd, rs, imm
--   and rd, rs, ro
--   andi rd, rs, imm
--   not rd, rs
--
-- -- Port
--   pl rd, P
--   ps P, rs
--
-- -- Jump
--   jlr rd, label
--
-- -- Memory
--   lb rd, rs, imm
--   lbu rd, rs, imm
--   lh rd, rs, imm
--   lhu rd, rs, imm
--   lw rd, rs, imm
--   sb rd, rs, imm
--   sh rd, rs, imm
--   sw rd, rs, imm
--
-- -- Comparison
--   slt rd, rs, ro
--   slti rd, rs, imm
--   sltu rd, rs, ro
--   sltui rd, rs, imm
--
-- -- Environment
--   ecall
--   ebreak
--
local oku32_isa = {}

ffi.cdef[[
union yatm_oku_oku32_ins {
  int32_t i32;
  uint32_t u32;
  struct o {
    int8_t opcode : 7;
    int32_t imm : 25;
  };
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
};
]]

oku32_isa._native = ffi.new("yatm_oku_oku32_ins")

function oku32_isa.step(oku)
  local pc = oku.registers.pc
  local ins = oku.memory:i32(pc)

  oku32_isa._native.i32 = ins

  -- add
  if oku32_isa._native.o.opcode == 0x00 then
  -- addi
  end
end

yatm_oku.OKU.isa.OKU32 = oku32_isa
