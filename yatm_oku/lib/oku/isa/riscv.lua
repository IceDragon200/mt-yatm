--
-- The RISCV ISA.
--
-- With 2 new instructions for interacting with YATM data's port system.
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
local ffi = assert(yatm_oku.ffi)
local bit = assert(yatm_oku.bit)

ffi.cdef[[
union yatm_oku_rv32i_syn {
  int32_t xlen;
  uint32_t uxlen;
  int32_t i32;
  uint32_t u32;
  struct {
    int32_t lo : 12;
    int32_t hi : 20;
  } lui;
  struct {
    int8_t lo : 5;
    int8_t hi : 7;
    int32_t unused : 20;
  } boffset12;
};
]]

ffi.cdef[[
union yatm_oku_rv32i_ins {
  int32_t  i32;
  uint32_t u32;
  struct {
    int8_t iflag : 2;
    int8_t opcode : 5;
    int32_t rest : 25;
  } head;
  struct {
    int8_t iflag : 2;
    int8_t opcode : 5;
    int8_t rd : 5;
    int8_t funct3 : 3;
    int8_t rs1 : 5;
    int8_t rs2 : 5;
    int8_t funct7 : 7;
  } r;
  struct {
    int8_t iflag : 2;
    int8_t opcode : 5;
    int8_t rd : 5;
    int8_t funct3 : 3;
    int8_t rs1 : 5;
    union {
      int16_t imm12 : 12;
      struct {
        int8_t imm12lo : 6;
        int8_t imm12hi : 6;
      };
    };
  } i;
  struct {
    int8_t iflag : 2;
    int8_t opcode : 5;
    int8_t imm0 : 5;
    int8_t funct3 : 3;
    int8_t rs1 : 5;
    int8_t rs2 : 5;
    int8_t imm1 : 7;
  } s;
  struct {
    int8_t iflag : 2;
    int8_t opcode : 5;
    int8_t rd : 5;
    int32_t imm : 20;
  } u;
  struct {
    int8_t iflag : 2;
    int8_t opcode : 5;
    union {
      struct {
        int8_t imm0 : 1;
        int8_t imm1 : 4;
      };
      int8_t bimm12lo : 5;
    };
    int8_t funct3 : 3;
    int8_t rs1 : 5;
    int8_t rs2 : 5;
    union {
      struct {
        int8_t imm2 : 6;
        int8_t imm3 : 1;
      };
      int8_t bimm12lo : 7;
    };
  } b;
  struct {
    int8_t iflag : 2;
    int8_t opcode : 5;
    int8_t rd : 5;
    union {
      int32_t imm20 : 20;
      struct {
        int8_t  imm8 : 8;
        int8_t  imm1_0 : 1;
        int16_t imm10 : 10;
        int8_t  imm1_1 : 1;
      };
    };
  } j;
};
]]

local isa = {}
isa._native = ffi.new("union yatm_oku_rv32i_ins")
isa._syn = ffi.new("union yatm_oku_rv32i_syn")

function isa.xr_i32(ri, oku)
  if ri == 0 then
    return 0
  end
  return oku.registers.x[ri].i32
end

function isa.xr_u32(ri, oku)
  if ri == 0 then
    return 0
  end
  return oku.registers.x[ri].u32
end

function isa.w_xr_u32(ri, value, oku)
  if ri == 0 then
    return
  end
  oku.registers.x[ri].i32 = value
end

function isa.w_xr_i32(ri, value, oku)
  if ri == 0 then
    return
  end
  oku.registers.x[ri].i32 = value
end

isa.OPCODE_TO_INS = {
  [0x00] = "load",
  [0x04] = "arithi",
  [0x05] = "auipc",
  [0x08] = "store",
  [0x0C] = "arith",
  [0x0D] = "lui",
  [0x18] = "branch",
  [0x19] = "jalr",
  [0x1B] = "jal",
  [0x1C] = "system",
}
isa.ins = {}

function isa.ins.load(i, oku)
  local rd = i.i.rd
  local rs1 = i.i.rs1
  local imm12 = i.i.imm12
  local m = isa.xr_i32(rs1, oku) + imm12

  if i.i.funct3 == 0 then
    -- lb
    oku.memory:i8(m)
  elseif i.i.funct3 == 1 then
    -- lh
    oku.memory:i16(m)
  elseif i.i.funct3 == 2 then
    -- lw
    oku.memory:i32(m)
  elseif i.i.funct3 == 3 then
    -- ld
    oku.memory:i64(m)
  elseif i.i.funct3 == 4 then
    -- lbu
    oku.memory:u8(m)
  elseif i.i.funct3 == 5 then
    -- lhu
    oku.memory:u16(m)
  elseif i.i.funct3 == 6 then
    -- lwu
    oku.memory:u32(m)
  end
end

-- Arithmetic with Immediate
function isa.ins.arithi(i, oku)
  local rd = i.i.rd
  local rs1 = i.i.rs1
  if i.i.funct3 == 0 then
    -- addi
    local value = isa.xr_i32(rs1, oku) + i.i.imm12
    isa.w_xr_i32(rd, value, oku)
  elseif i.i.funct3 == 1 then
    -- slli
    error("not implemented slli")
  elseif i.i.funct3 == 2 then
    -- slti
    error("not implemented slti")
  elseif i.i.funct3 == 3 then
    -- sltiu
    error("not implemented sltiu")
  elseif i.i.funct3 == 4 then
    -- xori
    local value = bit.bxor(isa.xr_i32(rs1, oku), i.i.imm12)
    isa.w_xr_i32(rd, value, oku)
  elseif i.i.funct3 == 5 then
    -- srli & srai
    error("not implemented srli and srai")
  elseif i.i.funct3 == 6 then
    -- ori
    local value = bit.bor(isa.xr_i32(rs1, oku), i.i.imm12)
    isa.w_xr_i32(rd, value, oku)
  elseif i.i.funct3 == 7 then
    -- andi
    local value = bit.band(isa.xr_i32(rs1, oku), i.i.imm12)
    isa.w_xr_i32(rd, value, oku)
  else
    error("unexpected funct3", i.r.funct3)
  end
end

-- Store
function isa.ins.store(i, oku)
  isa._syn.i32 = 0
  isa._syn.boffset12.lo = i.b.bimm12lo
  isa._syn.boffset12.hi = i.b.bimm12hi

  local v1 = isa.xr_i32(i.b.rs1, oku) + isa._syn.i32
  local v2 = isa.xr_i32(i.b.rs2, oku)

  if i.i.funct3 == 0 then
    -- sb
    oku.memory:w_i8(v1, v2)
  elseif i.i.funct3 == 1 then
    -- sh
    oku.memory:w_i16(v1, v2)
  elseif i.i.funct3 == 2 then
    -- sw
    oku.memory:w_i32(v1, v2)
  elseif i.i.funct3 == 3 then
    -- sd
    oku.memory:w_i64(v1, v2)
  end
end

-- Arithmetic with Register
function isa.ins.arith(i, oku)
  local rd = i.r.rd
  local rs1 = i.r.rs1
  local rs2 = i.r.rs2

  local v1 = isa.xr_i32(rs1, oku)
  local v1u = isa.xr_u32(rs1, oku)
  local v2 = isa.xr_i32(rs2, oku)
  local v2u = isa.xr_u32(rs2, oku)

  if i.r.funct7 == 1 then
    -- RV32M
    if i.r.funct3 == 0 then
      -- mul
      isa.w_xr_i32(i, v1 * v2, oku)
    elseif i.r.funct3 == 1 then
      -- mulh
      error("not implemented: mulh")
    elseif i.r.funct3 == 2 then
      -- mulhsu
      error("not implemented: mulhsu")
    elseif i.r.funct3 == 3 then
      -- mulhu
      error("not implemented: mulhu")
    elseif i.r.funct3 == 4 then
      -- div
      if v2 == 0 then
        error("DivisionByZero")
      else
        isa.w_xr_i32(i, v1 / v2, oku)
      end
    elseif i.r.funct3 == 5 then
      -- divu
      if v2u == 0 then
        error("DivisionByZero")
      else
        isa.w_xr_u32(i, v1u / v2u, oku)
      end
    elseif i.r.funct3 == 6 then
      -- rem
      if v2 == 0 then
        error("DivisionByZero")
      else
        isa.w_xr_i32(i, v1 % v2, oku)
      end
    elseif i.r.funct3 == 7 then
      -- remu
      if v2u == 0 then
        error("DivisionByZero")
      else
        isa.w_xr_u32(i, v1u % v2u, oku)
      end
    end
  else
    -- RV32I
    if i.r.funct3 == 0 then
      if i.r.funct7 == 0 then
        -- add
        isa.w_xr_i32(rd, v1 + v2, oku)
      elseif i.r.funct7 == 32 then
        -- sub
        isa.w_xr_i32(rd, v1 - v2, oku)
      else
        error("unexpected funct7", i.r.funct7)
      end
    elseif i.r.funct3 == 1 then
      -- sll
      error("unimplemented: sll")
    elseif i.r.funct3 == 2 then
      -- slt
      error("unimplemented: slt")
    elseif i.r.funct3 == 3 then
      -- sltu
      error("unimplemented: sltu")
    elseif i.r.funct3 == 4 then
      -- xor
      isa.w_xr_i32(rd, bit.bxor(v1, v2), oku)
    elseif i.r.funct3 == 5 then
      -- srl & sra
      error("unimplemented: srl & sra")
    elseif i.r.funct3 == 6 then
      -- or
      isa.w_xr_i32(rd, bit.bor(v1, v2), oku)
    elseif i.r.funct3 == 7 then
      -- and
      isa.w_xr_i32(rd, bit.band(v1, v2), oku)
    else
      error("unexpected funct3", i.r.funct3)
    end
  end
end

function isa.ins.lui(i, oku)
  local rd = i.j.rd
  local imm20 = i.j.imm20

  local value = isa.xr_i32(rd, oku)

  isa._syn.i32 = value
  isa._syn.lui.hi = imm20

  isa.xr_i32(rd, isa._syn.i32, oku)
end

function isa.ins.branch(i, oku)
  isa._syn.i32 = 0
  isa._syn.boffset12.lo = i.b.bimm12lo
  isa._syn.boffset12.hi = i.b.bimm12hi

  local offset = isa._syn.i32
  local new_pc = oku.registers.pc.i32 + offset
  local v1 = isa.xr_i32(i.b.rs1, oku)
  local v1u = isa.xr_u32(i.b.rs1, oku)
  local v2 = isa.xr_i32(i.b.rs2, oku)
  local v2u = isa.xr_u32(i.b.rs2, oku)

  if i.b.funct3 == 0 then
    -- beq
    if v1 == v2 then
      oku.registers.pc.i32 = new_pc
    end
  elseif i.b.funct3 == 1 then
    -- bne
    if v1 ~= v2 then
      oku.registers.pc.i32 = new_pc
    end
  elseif i.b.funct3 == 4 then
    -- blt
    if v1 < v2 then
      oku.registers.pc.i32 = new_pc
    end
  elseif i.b.funct3 == 5 then
    -- bge
    if v1 >= v2 then
      oku.registers.pc.i32 = new_pc
    end
  elseif i.b.funct3 == 6 then
    -- bltu
    if v1u < v2u then
      oku.registers.pc.i32 = new_pc
    end
  elseif i.b.funct3 == 7 then
    -- bgeu
    if v1u >= v2u then
      oku.registers.pc.i32 = new_pc
    end
  else
    error("invalid instruction")
  end
end

function isa.ins.jalr(i, oku)
  local rd = i.i.rd
  local rs1 = i.i.rs1
  local imm12 = i.i.imm12

  local pc = oku.registers.pc.i32

  if i.i.funct3 == 0 then
    local offset = isa.xr_i32(rs1, oku) + imm12
    isa.w_xr_i32(rd, pc, oku)
    oku.registers.pc.i32 = pc + offset
  else
    error("invalid instruction")
  end
end

function isa.ins.jal(i, oku)
  local rd = i.i.rd
  local jimm20 = i.i.imm20

  local pc = oku.registers.pc.i32

  if i.i.funct3 == 0 then
    local offset = jimm20
    isa.w_xr_i32(rd, pc, oku)
    oku.registers.pc.i32 = pc + offset
  else
    error("invalid instruction")
  end
end

function isa.ins.system(i, oku)
  if i.i.funct3 == 0 then
    if i.i.rd == 0 and i.i.rs1 == 0 then
      if i.i.imm12 == 0x000 then
        -- ecall
        error("TODO: ecall")
      elseif i.i.imm12 == 0x001 then
        -- ebreak
        error("TODO: ebreak")
      elseif i.i.imm12 == 0x002 then
        -- uret
        error("not implemented: uret")
      elseif i.i.imm12 == 0x102 then
        -- sret
        error("not implemented: sret")
      elseif i.i.imm12 == 0x302 then
        -- mret
        error("not implemented: mret")
      elseif i.i.imm12 == 0x7b2 then
        -- dret
        error("not implemented: dret")
      elseif i.i.imm12 == 0x009 then
        -- sfence.vma
        error("not implemented: sfence.vma")
      elseif i.i.imm12 == 0x105 then
        -- wfi
        error("not implemented: wfi")
      end
    end
  else
    -- csr extensions
    error("not implemented: csr")
  end
end

function isa.step(oku)
  local pc = oku.registers.pc
  isa._native.i32 = oku.memory:i32(math.floor(pc / 4))

  if isa._native.head.iflag == 3 then
    local ins_name = assert(isa.OPCODE_TO_INS[isa._native.head.opcode])
    isa.ins[ins_name](isa._native, oku)
  else
    -- TODO: error
  end
end

yatm_oku.OKU.isa.RISCV = isa
