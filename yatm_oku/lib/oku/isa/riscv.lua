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
local bit = assert(yatm_oku.bit)
local ffi = assert(yatm_oku.ffi)

ffi.cdef[[
union yatm_oku_rv32i_itypes {
  union {
    int32_t i32;
    uint32_t u32;
  };
  union {
    struct {
      int16_t i16h;
      int16_t i16l;
    };
    struct {
      uint16_t u16h;
      uint16_t u16l;
    };
    int16_t i16v[2];
    uint16_t ui16v[2];
  };
  union {
    struct {
      int8_t i8_0;
      int8_t i8_1;
      int8_t i8_2;
      int8_t i8_3;
    };
    struct {
      uint8_t u8_0;
      uint8_t u8_1;
      uint8_t u8_2;
      uint8_t u8_3;
    };
    int8_t i8v[4];
    uint8_t u8v[4];
  };
};
]]
local isa = {}
--isa._native = ffi.new("union yatm_oku_rv32i_ins")
isa._itype = ffi.new("union yatm_oku_rv32i_itypes")

isa._native = {
  i32 = 0,
  u32 = 0,
  head = {
    iflag = 0,
    opcode = 0,
    rest = 0,
  },
  r = {
    iflag = 0,
    opcode = 0,
    rd = 0,
    funct3 = 0,
    rs1 = 0,
    rs2 = 0,
    funct7 = 0,
  },
  i = {
    iflag = 0,
    opcode = 0,
    rd = 0,
    funct3 = 0,
    rs1 = 0,
    imm12 = 0,
    imm12lo = 0,
    imm12hi = 0,
  },
  s = {
    iflag = 0,
    opcode = 0,
    imm0 = 0,
    funct3 = 0,
    rs1 = 0,
    rs2 = 0,
    imm1 = 0,
  },
  u = {
    iflag = 0,
    opcode = 0,
    rd = 0,
    imm = 0,
  },
  b = {
    iflag = 0,
    opcode = 0,
    bimm12lo = 0,
    imm0 = 0,
    imm1 = 0,
    funct3 = 0,
    rs1 = 0,
    rs2 = 0,
    imm2 = 0,
    imm3 = 0,
    bimm12hi = 0
  },
  j = {
    iflag = 0,
    opcode = 0,
    rd = 0,
    imm20 = 0,
    imm8 = 0,
    imm1_0 = 0,
    imm10 = 0,
    imm1_1 = 0,
  }
}

local function format_hex(size, value)
  return string.format("0x%0" .. size .. "x", value)
end

local function format_bin(size, value, break_point)
  local result = {}
  local i = 0
  local digits = 0
  while value > 0 do
    local bit_value = bit.band(value, 1)
    if i >= break_point then
      table.insert(result, "_")
      i = 0
    end
    table.insert(result, bit_value)
    value = bit.rshift(value, 1)
    digits = digits + 1
    i = i + 1
  end
  while digits < size do
    if i >= break_point then
      table.insert(result, "_")
      i = 0
    end
    table.insert(result, "0")
    digits = digits + 1
    i = i + 1
  end
  result = yatm_core.list_reverse(result)
  result = table.concat(result, "")

  return "0b" .. result
end

function isa:encode_syn_lui(hi, lo)
  local i = bit.bor(bit.lshift(bit.band(hi, 0xFFFFF), 12), bit.band(lo, 0xFFF))

  isa._itype.i32 = i

  return {
    i32 = isa._itype.i32,
    u32 = isa._itype.u32,
  }
end

function isa:encode_syn_boffset12(hi, lo)
  local i = bit.band(bit.bor(bit.lshift(bit.band(hi, 0x7F), 5), bit.band(lo, 0x1F)), 0xFFF)

  isa._itype.i32 = i

  return {
    i32 = isa._itype.i32,
    u32 = isa._itype.u32,
  }
end

function isa:decode_head_ins(value, result)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint32_t rest : 25;
  } head;
  ]]
  result = result or {}
  result.iflag = bit.band(value, 0x3)
  value = bit.rshift(value, 2)
  result.opcode = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  return value, result
end

function isa:decode_r_ins(value, result)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t rd : 5;
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    uint8_t rs2 : 5;
    uint8_t funct7 : 7;
  } r;
  ]]
  local value, result = self:decode_head_ins(value, result)

  result.rd = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.funct3 = bit.band(value, 0x7)
  value = bit.rshift(value, 3)
  result.rs1 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.rs2 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.funct7 = bit.band(value, 0x7F)
  value = bit.rshift(value, 7)

  return value, result
end

function isa:decode_i_ins(value, result)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t rd : 5;
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    union {
      uint16_t imm12 : 12;
      struct {
        uint8_t imm12lo : 6;
        uint8_t imm12hi : 6;
      };
    };
  } i;
  ]]
  local value, result = self:decode_head_ins(value, result)

  result.rd = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.funct3 = bit.band(value, 0x7)
  value = bit.rshift(value, 3)
  result.rs1 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.imm12 = bit.band(value, 0x3FF)
  value = bit.rshift(value, 12)

  result.imm12lo = bit.band(result.imm12, 0x3f)
  result.imm12hi = bit.band(bit.rshift(result.imm12, 6), 0x3f)
  return value, result
end

function isa:decode_s_ins(value, result)
  --[[
    struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t imm0 : 5;
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    uint8_t rs2 : 5;
    uint8_t imm1 : 7;
  } s;
  ]]
  local value, result = self:decode_head_ins(value)

  result.imm0 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.funct3 = bit.band(value, 0x7)
  value = bit.rshift(value, 3)
  result.rs1 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.rs2 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.imm1 = bit.band(value, 0x7F)
  value = bit.rshift(value, 7)

  return value, result
end

function isa:decode_u_ins(value)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t rd : 5;
    uint32_t imm : 20;
  } u;
  ]]
  local value, result = self:decode_head_ins(value)

  result.rd = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.imm = bit.band(value, 0xFFFFF)
  value = bit.rshift(value, 20)

  return value, result
end

function isa:decode_b_ins(value)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    union {
      uint8_t bimm12lo : 5;
      struct {
        uint8_t imm0 : 1;
        uint8_t imm1 : 4;
      };
    };
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    uint8_t rs2 : 5;
    union {
      uint8_t bimm12hi : 7;
      struct {
        uint8_t imm2 : 6;
        uint8_t imm3 : 1;
      };
    };
  } b;
  ]]
  local value, result = self:decode_head_ins(value)

  result.bimm12lo = bit.band(value, 0x1F)

  local lo = result.bimm12lo
  result.imm0 = bit.band(lo, 0x1)
  lo = bit.rshift(lo, 1)
  result.imm1 = bit.band(lo, 0xF)

  value = bit.rshift(value, 5)

  result.funct3 = bit.band(lo, 0x7)
  value = bit.rshift(value, 3)
  result.rs1 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.rs2 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)

  result.bimm12hi = bit.band(value, 0x7F)
  local hi = result.bimm12hi
  result.imm2 = bit.band(hi, 0x3F)
  hi = bit.rshift(hi, 6)
  result.imm3 = bit.band(hi, 0x1)

  value = bit.rshift(value, 7)

  return value, result
end

function isa:decode_j_ins(value)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t rd : 5;
    union {
      uint32_t imm20 : 20;
      struct {
        uint8_t  imm8 : 8;
        uint8_t  imm1_0 : 1;
        uint16_t imm10 : 10;
        uint8_t  imm1_1 : 1;
      };
    };
  } j;
  ]]
  local value, result = self:decode_head_ins(value)

  result.rd = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.imm20 = bit.band(value, 0xFFFFF)

  result.imm8 = bit.band(value, 0xFF)
  value = bit.rshift(value, 8)
  result.imm1_0 = bit.band(value, 0x1)
  value = bit.rshift(value, 1)
  result.imm10 = bit.band(value, 0x3FF)
  value = bit.rshift(value, 10)
  result.imm1_1 = bit.band(value, 0x1)
  value = bit.rshift(value, 1)

  return value, result
end

--
-- Load Header
--
function isa:load_head(u32_ins)
  self._itype.u32 = u32_ins
  self._native.u32 = self._itype.u32
  self._native.i32 = self._itype.i32

  self:decode_head_ins(self._native.u32, self._native.head)
  self:debug_native_head()
end

--
-- Load From Native
--
function isa:nload_r_ins()
  self:decode_r_ins(self._native.u32, self._native.r)
  self:debug_native_r()
end

function isa:nload_i_ins()
  self:decode_i_ins(self._native.u32, self._native.i)
  self:debug_native_i()
end

function isa:nload_s_ins()
  self:decode_s_ins(self._native.u32, self._native.s)
  self:debug_native_s()
end

function isa:nload_b_ins()
  self:decode_b_ins(self._native.u32, self._native.b)
  self:debug_native_b()
end

function isa:nload_j_ins()
  self:decode_j_ins(self._native.u32, self._native.j)
  self:debug_native_j()
end

function isa:debug_native_head()
  local n = self._native
  print("rv32i_ins.head", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                          "rest:" .. format_hex(8, n.head.rest),
                          "opcode:" .. format_hex(2, n.head.opcode),
                          "iflag:" .. format_hex(1, n.head.iflag)
        )
end

function isa:debug_native_b()
  local n = self._native
  print("rv32i_ins.b", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                       "bimm12hi:" .. format_hex(2, n.b.bimm12hi) .. "(" .. format_hex(1, n.b.imm3) .. " " .. format_hex(2, n.b.imm2) .. ")",
                       "rs2:" .. format_hex(2, n.b.rs2),
                       "rs1:" .. format_hex(2, n.b.rs1),
                       "funct3:" .. format_hex(1, n.b.funct3),
                       "bimm12lo:" .. format_hex(2, n.b.bimm12lo) .. "(" .. format_hex(1, n.b.imm1) .. " " .. format_hex(1, n.b.imm0) .. ")",
                       "opcode:" .. format_hex(2, n.b.opcode),
                       "iflag:" .. format_hex(1, n.b.iflag)
        )
end

function isa:debug_native_i()
  local n = self._native
  print("rv32i_ins.i", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                       "imm12:" .. format_hex(4, n.i.imm12),
                       "rs1:" .. format_hex(2, n.i.rs1),
                       "funct3:" .. format_hex(1, n.i.funct3),
                       "rd:" .. format_hex(2, n.i.rd),
                       "opcode:" .. format_hex(2, n.i.opcode) .. "(" .. format_bin(5, n.i.opcode, 4) .. ")",
                       "iflag:" .. format_hex(1, n.i.iflag)
        )
end

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
  oku.registers.x[ri].u32 = value
end

function isa.w_xr_i32(ri, value, oku)
  if ri == 0 then
    return
  end
  oku.registers.x[ri].i32 = value
end

isa.REGISTER_NAME = {}
for i = 0,31 do
  isa.REGISTER_NAME[i] = "x" .. i
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
  isa:nload_i_ins()
  local rd = i.i.rd
  local rs1 = i.i.rs1
  local imm12 = i.i.imm12
  local m = isa.xr_i32(rs1, oku) + imm12

  if i.i.funct3 == 0 then
    -- lb
    oku.memory:r_i8(m)
  elseif i.i.funct3 == 1 then
    -- lh
    oku.memory:r_i16(m)
  elseif i.i.funct3 == 2 then
    -- lw
    oku.memory:r_i32(m)
  elseif i.i.funct3 == 3 then
    -- ld
    oku.memory:r_i64(m)
  elseif i.i.funct3 == 4 then
    -- lbu
    oku.memory:r_u8(m)
  elseif i.i.funct3 == 5 then
    -- lhu
    oku.memory:r_u16(m)
  elseif i.i.funct3 == 6 then
    -- lwu
    oku.memory:r_u32(m)
  end
end

-- Arithmetic with Immediate
function isa.ins.arithi(i, oku)
  isa:nload_i_ins()
  local rd = i.i.rd
  local rs1 = i.i.rs1
  if i.i.funct3 == 0 then
    -- addi
    local value = isa.xr_i32(rs1, oku) + i.i.imm12
    print("ADDI", isa.REGISTER_NAME[rd], value)
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
    print("XORI", isa.REGISTER_NAME[rd], value)
    isa.w_xr_i32(rd, value, oku)
  elseif i.i.funct3 == 5 then
    -- srli & srai
    error("not implemented srli and srai")
  elseif i.i.funct3 == 6 then
    -- ori
    local value = bit.bor(isa.xr_i32(rs1, oku), i.i.imm12)
    print("ORI", isa.REGISTER_NAME[rd], value)
    isa.w_xr_i32(rd, value, oku)
  elseif i.i.funct3 == 7 then
    -- andi
    local value = bit.band(isa.xr_i32(rs1, oku), i.i.imm12)
    print("ANDI", isa.REGISTER_NAME[rd], value)
    isa.w_xr_i32(rd, value, oku)
  else
    error("unexpected funct3:" .. i.r.funct3)
  end
end

-- Store
function isa.ins.store(i, oku)
  isa:nload_b_ins()

  local offset = isa:encode_syn_boffset12(i.b.bimm12hi, i.b.bimm12lo).i32
  local v1 = isa.xr_i32(i.b.rs1, oku) + offset
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
  isa:nload_r_ins()
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
        error("unexpected funct7:" .. i.r.funct7)
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
      error("unexpected funct3:" .. i.r.funct3)
    end
  end
end

function isa.ins.lui(i, oku)
  isa:nload_i_ins()
  local rd = i.j.rd
  local imm20 = i.j.imm20

  local value = isa.xr_i32(rd, oku)

  local lui_offset = self:encode_syn_lui(imm20, value).i32

  isa.xr_i32(rd, lui_offset, oku)
end

function isa.ins.branch(i, oku)
  isa:nload_b_ins()
  local offset =  isa:encode_syn_boffset12(i.b.bimm12hi, i.b.bimm12lo).i32
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
  isa:nload_i_ins()
  local rd = i.i.rd
  local rs1 = i.i.rs1
  local imm12 = i.i.imm12
  local funct3 = i.i.funct3

  local pc = oku.registers.pc.i32

  if funct3 == 0x0 then
    local offset = isa.xr_i32(rs1, oku) + imm12
    if rs1 == 0x1 then
      print("RET", isa.REGISTER_NAME[rd], offset)
    else
      print("JALR", isa.REGISTER_NAME[rd], offset)
    end
    isa.w_xr_i32(rd, pc, oku)
    oku.registers.pc.i32 = pc + offset
  else
    error("invalid 'jalr' instruction (got funct3:" .. funct3 .. ")")
  end
end

function isa.ins.jal(i, oku)
  isa:nload_i_ins()
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
  isa:nload_i_ins()
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
  oku.exec_counter = oku.exec_counter + 1
  local pc = oku.registers.pc.u32
  print(oku.exec_counter, "PC", string.format("%08x", pc))
  isa:load_head(oku.memory:r_u32(pc))

  if isa._native.head.iflag == 0x3 then
    local ins_name = assert(isa.OPCODE_TO_INS[isa._native.head.opcode])
    print(oku.exec_counter, "STEP", ins_name, string.format("%08x", isa._native.u32))
    isa.ins[ins_name](isa._native, oku)
    oku.registers.pc.u32 = oku.registers.pc.u32 + 4
  else
    error(oku.exec_counter .. " Bad instruction " .. string.format("%08x", isa._native.u32))
    -- TODO: error
  end
end

yatm_oku.OKU.isa.RISCV = isa
