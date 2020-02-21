--
-- The RISCV ISA.
--
-- rd - register destination
-- rs - register source
-- ro - register as operand
-- imm - immediate value (i.e. an integer)
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
    imm12_0_5 = 0,
    funct3 = 0,
    rs1 = 0,
    rs2 = 0,
    imm12_5_7 = 0,
    --
    imm12 = 0,
    s_imm12 = 0,
  },
  u = {
    iflag = 0,
    opcode = 0,
    rd = 0,
    imm20 = 0,
  },
  b = {
    iflag = 0,
    opcode = 0,
    imm13_11_1 = 0,
    imm13_1_4 = 0,
    funct3 = 0,
    rs1 = 0,
    rs2 = 0,
    imm13_5_6 = 0,
    imm13_12_1 = 0,
    --
    imm13 = 0,
    s_imm13 = 0
  },
  j = {
    iflag = 0,
    opcode = 0,
    rd = 0,
    imm21_12_8 = 0,
    imm21_11_1 = 0,
    imm21_1_10 = 0,
    imm21_20_1 = 0,
    --
    imm21 = 0,
    s_imm21 = 0,
  }
}

local function format_hex(size, value)
  return string.format("0x%0" .. size .. "x", value)
end

local function format_bin(size, value, break_point)
  local break_point = break_point or size + 1
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

local function to_signed(bits, value)
  local signed = bit.band(bit.rshift(value, bits - 1), 0x1)
  --print("to_signed", format_bin(1, signed, 4), format_bin(bits, value, 4))
  if signed == 1 then
    local mask = math.pow(2, bits - 1) - 1
    local base = bit.band(value, mask)
    local max = math.pow(2, bits)
    local last_bit = bit.lshift(1, bits - 1) - max
    --print("to_signed", format_bin(1, signed, 4), format_bin(bits, value, 4), format_bin(bits, result, 4))
    return bit.bor(last_bit, base)
  else
    return value
  end
end

local function ensure_aligned_address(address)
  if math.floor(address / 4) * 4 == address then
    return true, nil
  else
    return false, "instruction-address-misaligned"
  end
end

local function attempt_jump(new_pc, oku)
  local aligned, err = ensure_aligned_address(new_pc)
  if not aligned then
    return false, err
  end
  oku.registers.pc.u32 = new_pc
  return true, nil
end

function isa:encode_syn_lui(hi, lo)
  assert(hi, "expected hi value")
  assert(lo, "expected lo value") -- usually from a register
  local i = bit.bor(bit.lshift(bit.band(hi, 0xFFFFF), 12), bit.band(lo, 0xFFF))

  isa._itype.i32 = i

  return {
    i32 = isa._itype.i32,
    u32 = isa._itype.u32,
  }
end

-- TODO: remove
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
  assert(result, "expected a target result map")
  result.iflag = bit.band(value, 0x3)
  value = bit.rshift(value, 2)
  result.opcode = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.rest = value
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
  result.imm12 = bit.band(value, 0xFFF)
  result.s_imm12 = to_signed(12, result.imm12)
  value = bit.rshift(value, 12)

  result.imm12lo = bit.band(result.imm12, 0x3F)
  result.imm12hi = bit.band(bit.rshift(result.imm12, 6), 0x3F)
  return value, result
end

function isa:decode_s_ins(value, result)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t imm12_0_4 : 5;
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    uint8_t rs2 : 5;
    uint8_t imm12_5_7 : 7;
  } s;
  ]]
  local value, result = self:decode_head_ins(value, result)

  result.imm12_0_4 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.funct3 = bit.band(value, 0x7)
  value = bit.rshift(value, 3)
  result.rs1 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.rs2 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.imm12_5_7 = bit.band(value, 0x7F)
  value = bit.rshift(value, 7)

  result.imm12 = bit.bor(bit.lshift(result.imm12_5_7, 5), result.imm12_0_4)
  result.s_imm12 = to_signed(12, result.imm12)

  return value, result
end

function isa:decode_u_ins(value, result)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t rd : 5;
    uint32_t imm20 : 20;
  } u;
  ]]
  local value, result = self:decode_head_ins(value, result)

  result.rd = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.imm20 = bit.band(value, 0xFFFFF)
  value = bit.rshift(value, 20)
  result.s_imm20 = to_signed(20, result.imm20)

  return value, result
end

function isa:decode_b_ins(value, result)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t imm13_11_1 : 1;
    uint8_t imm13_1_4 : 4;
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    uint8_t rs2 : 5;
    uint8_t imm13_5_6 : 6;
    uint8_t imm13_12_1 : 1;
  } b;
  ]]
  local value, result = self:decode_head_ins(value, result)

  result.imm13_11_1 = bit.band(value, 0x1)
  value = bit.rshift(value, 1)
  result.imm13_1_4 = bit.band(value, 0xF)
  value = bit.rshift(value, 4)

  result.funct3 = bit.band(value, 0x7)
  value = bit.rshift(value, 3)
  result.rs1 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)
  result.rs2 = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)

  result.imm13_5_6 = bit.band(value, 0x3F)
  value = bit.rshift(value, 6)
  result.imm13_12_1 = bit.band(value, 0x1)
  value = bit.rshift(value, 1)

  result.imm13 = bit.lshift(result.imm13_12_1, 12) +
                 bit.lshift(result.imm13_11_1, 11) +
                 bit.lshift(result.imm13_5_6, 5) +
                 bit.lshift(result.imm13_1_4, 1)

  result.s_imm13 = to_signed(13, result.imm13)

  return value, result
end

function isa:decode_j_ins(org_value, result)
  --[[
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t rd : 5;
    uint8_t  imm21_12_8 : 8;
    uint8_t  imm21_11_1 : 1;
    uint16_t imm21_1_10 : 10;
    uint8_t  imm21_20_1 : 1;
  } j;
  ]]
  local value, result = self:decode_head_ins(org_value, result)

  result.rd = bit.band(value, 0x1F)
  value = bit.rshift(value, 5)

  result.imm21_12_8 = bit.band(value, 0xFF)
  value = bit.rshift(value, 8)
  result.imm21_11_1 = bit.band(value, 0x1)
  value = bit.rshift(value, 1)
  result.imm21_1_10 = bit.band(value, 0x3FF)
  value = bit.rshift(value, 10)
  result.imm21_20_1 = bit.band(value, 0x1)
  value = bit.rshift(value, 1)

  -- imm21 is a god damn odd ball, its parts are all over the place...
  result.imm21 = bit.lshift(result.imm21_20_1, 20) +
                 bit.lshift(result.imm21_12_8, 12) +
                 bit.lshift(result.imm21_11_1, 11) +
                 bit.lshift(result.imm21_1_10, 1)
  result.s_imm21 = to_signed(21, result.imm21)

  return value, result
end

--
-- Load Header
--
function isa:load_head(i32_ins)
  self._itype.i32 = i32_ins
  self._native.u32 = self._itype.u32
  self._native.i32 = self._itype.i32

  self:decode_head_ins(self._native.i32, self._native.head)
  --self:debug_native_head()
end

--
-- Load From Native
--
function isa:nload_r_ins()
  self:decode_r_ins(self._native.i32, self._native.r)
  --self:debug_native_r()
end

function isa:nload_i_ins()
  self:decode_i_ins(self._native.i32, self._native.i)
  --self:debug_native_i()
end

function isa:nload_s_ins()
  self:decode_s_ins(self._native.i32, self._native.s)
  --self:debug_native_s()
end

function isa:nload_u_ins()
  self:decode_u_ins(self._native.i32, self._native.u)
  --self:debug_native_u()
end

function isa:nload_b_ins()
  self:decode_b_ins(self._native.i32, self._native.b)
  --self:debug_native_b()
end

function isa:nload_j_ins()
  self:decode_j_ins(self._native.i32, self._native.j)
  --self:debug_native_j()
end

function isa:debug_native_head()
  local n = self._native
  print("rv32i_ins.head", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                          "rest:" .. format_hex(8, n.head.rest),
                          "opcode:" .. format_hex(2, n.head.opcode),
                          "iflag:" .. format_hex(1, n.head.iflag)
        )
end

function isa:debug_native_i()
  local n = self._native
  print("rv32i_ins.i", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                       "imm12:" .. format_hex(3, n.i.imm12) .. "; s_imm12:" .. format_hex(3, n.i.s_imm12),
                       "rs1:" .. format_hex(2, n.i.rs1),
                       "funct3:" .. format_hex(1, n.i.funct3),
                       "rd:" .. format_hex(2, n.i.rd),
                       "opcode:" .. format_hex(2, n.i.opcode) .. "(" .. format_bin(5, n.i.opcode, 4) .. ")",
                       "iflag:" .. format_hex(1, n.i.iflag)
        )
end

function isa:debug_native_s()
  local n = self._native
  print("rv32i_ins.s", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                       "imm12_5_7:" .. format_hex(2, n.s.imm12_5_7),
                       "rs2:" .. format_hex(2, n.s.rs2),
                       "rs1:" .. format_hex(2, n.s.rs1),
                       "funct3:" .. format_hex(1, n.s.funct3),
                       "imm12_0_4:" .. format_hex(2, n.s.imm12_0_4),
                       "opcode:" .. format_hex(2, n.s.opcode),
                       "iflag:" .. format_hex(1, n.s.iflag)
        )
end

function isa:debug_native_u()
  local n = self._native
  print("rv32i_ins.u", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                       "imm20:" .. format_hex(8, n.u.imm20),
                       "rd:" .. format_hex(2, n.u.rd),
                       "opcode:" .. format_hex(2, n.u.opcode) .. "(" .. format_bin(5, n.u.opcode, 4) .. ")",
                       "iflag:" .. format_hex(1, n.u.iflag)
        )
end

function isa:debug_native_b()
  local n = self._native
  print("rv32i_ins.b", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                       "imm13_12_1:" .. format_hex(1, n.b.imm13_12_1),
                       "imm13_5_6:" .. format_hex(2, n.b.imm13_5_6),
                       "rs2:" .. format_hex(2, n.b.rs2),
                       "rs1:" .. format_hex(2, n.b.rs1),
                       "funct3:" .. format_hex(1, n.b.funct3),
                       "imm13_1_4:" .. format_hex(1, n.b.imm13_1_4),
                       "imm13_11_1:" .. format_hex(1, n.b.imm13_11_1),
                       "opcode:" .. format_hex(2, n.b.opcode),
                       "iflag:" .. format_hex(1, n.b.iflag)
        )
end


function isa:debug_native_j()
  local n = self._native
  print("rv32i_ins.j", format_hex(8, n.u32) .. "(" .. format_bin(32, n.u32, 4) .. ")", "|",
                       "imm21:" .. format_hex(6, n.j.imm21),
                       "rd:" .. format_hex(2, n.j.rd),
                       "opcode:" .. format_hex(2, n.j.opcode),
                       "iflag:" .. format_hex(1, n.j.iflag)
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

function isa.ins.load(i, _npc, oku)
  isa:nload_i_ins()
  local rd = i.i.rd
  local rs1 = i.i.rs1
  local offset = i.i.s_imm12
  local addr = isa.xr_i32(rs1, oku) + offset

  if i.i.funct3 == 0 then
    -- lb
    --print("LB", isa.REGISTER_NAME[rd], addr)
    isa.w_xr_i32(rd, oku:get_memory_i8(addr), oku)
  elseif i.i.funct3 == 1 then
    -- lh
    --print("LH", isa.REGISTER_NAME[rd], addr)
    isa.w_xr_i32(rd, oku:get_memory_i16(addr), oku)
  elseif i.i.funct3 == 2 then
    -- lw
    --print("LW", isa.REGISTER_NAME[rd], addr)
    isa.w_xr_i32(rd, oku:get_memory_i32(addr), oku)
  elseif i.i.funct3 == 3 then
    -- ld
    --print("LD", isa.REGISTER_NAME[rd], addr)
    isa.w_xr_i64(rd, oku:get_memory_i64(addr), oku)
  elseif i.i.funct3 == 4 then
    -- lbu
    --print("LBU", isa.REGISTER_NAME[rd], addr)
    isa.w_xr_u32(rd, oku:get_memory_u8(addr), oku)
  elseif i.i.funct3 == 5 then
    -- lhu
    --print("LHU", isa.REGISTER_NAME[rd], addr)
    isa.w_xr_u32(rd, oku:get_memory_u16(addr), oku)
  elseif i.i.funct3 == 6 then
    -- lwu
    --print("LWU", isa.REGISTER_NAME[rd], addr)
    isa.w_xr_u32(rd, oku:get_memory_u32(addr), oku)
  elseif i.i.funct3 == 7 then
    -- ldu
    --print("LDU", isa.REGISTER_NAME[rd], addr)
    isa.w_xr_u64(rd, oku:get_memory_u64(addr), oku)
  else
    print("unexpected load instruction funct3:" .. i.i.funct3)
  end
  return true, nil
end

local function decode_shift_imm12(imm12)
  local shamt = bit.band(imm12, 0x1F)
  local rest = bit.rshift(imm12, 5)
  return shamt, rest
end

-- Arithmetic with Immediate
function isa.ins.arithi(i, _npc, oku)
  isa:nload_i_ins()
  local rd = i.i.rd
  local rs1 = i.i.rs1
  local u_imm12 = i.i.imm12
  local s_imm12 = i.i.s_imm12
  if i.i.funct3 == 0 then
    -- addi
    local value = isa.xr_i32(rs1, oku) + s_imm12
    --print("ADDI", isa.REGISTER_NAME[rd], value)
    isa.w_xr_i32(rd, value, oku)
  elseif i.i.funct3 == 1 then
    -- slli
    local shamt, rest = decode_shift_imm12(s_imm12)
    if rest == 0 then
      local value = isa.xr_i32(rs1, oku)
      --print("SLLI", isa.REGISTER_NAME[rd], shamt)
      isa.w_xr_i32(rd, bit.lshift(value, shamt), oku)
    else
      error("illegal instruction")
    end
  elseif i.i.funct3 == 2 then
    -- slti
    local left = isa.xr_i32(rs1, oku)
    --print("SLTI", isa.REGISTER_NAME[rd], isa.REGISTER_NAME[rs1], s_imm12)
    if left < s_imm12 then
      isa.w_xr_i32(rd, 1, oku)
    else
      isa.w_xr_i32(rd, 0, oku)
    end
  elseif i.i.funct3 == 3 then
    -- sltiu
    --print("SLTIU", isa.REGISTER_NAME[rd], isa.REGISTER_NAME[rs1], s_imm12)
    local left = isa.xr_u32(rs1, oku)
    if left < u_imm12 then
      isa.w_xr_i32(rd, 1, oku)
    else
      isa.w_xr_i32(rd, 0, oku)
    end
  elseif i.i.funct3 == 4 then
    -- xori
    local value = bit.bxor(isa.xr_i32(rs1, oku), s_imm12)
    --print("XORI", isa.REGISTER_NAME[rd], value)
    isa.w_xr_i32(rd, value, oku)
  elseif i.i.funct3 == 5 then
    -- srli & srai
    local shamt, rest = decode_shift_imm12(s_imm12)
    if rest == 0 then
      --print("SRLI", isa.REGISTER_NAME[rd], shamt)
      local value = isa.xr_i32(rs1, oku)
      isa.w_xr_i32(rd, bit.rshift(value, shamt), oku)
    elseif rest == 0x20 then
      --print("SRAI", isa.REGISTER_NAME[rd], shamt)
      local value = isa.xr_i32(rs1, oku)
      isa.w_xr_i32(rd, bit.rshift(value, shamt), oku)
    else
      error("illegal instruction")
    end
  elseif i.i.funct3 == 6 then
    -- ori
    local value = bit.bor(isa.xr_i32(rs1, oku), s_imm12)
    --print("ORI", isa.REGISTER_NAME[rd], value)
    isa.w_xr_i32(rd, value, oku)
  elseif i.i.funct3 == 7 then
    -- andi
    local value = bit.band(isa.xr_i32(rs1, oku), s_imm12)
    --print("ANDI", isa.REGISTER_NAME[rd], value)
    isa.w_xr_i32(rd, value, oku)
  else
    error("unexpected funct3:" .. i.r.funct3)
  end
  return true, nil
end

-- Add Upper Immediate to PC
function isa.ins.auipc(i, npc, oku)
  isa:nload_u_ins()

  local offset = encode_syn_lui(i.u.imm20, 0).i32

  offset = npc + offset

  isa.w_xr_u32(rd, value, oku)
  return true, nil
end

-- Store
function isa.ins.store(i, _npc, oku)
  isa:nload_s_ins()

  local offset = i.s.s_imm12
  local base = isa.xr_i32(i.s.rs1, oku)
  local v2 = isa.xr_i32(i.s.rs2, oku)

  local addr = base + offset

  if i.s.funct3 == 0 then
    -- sb
    local v = bit.band(v2, 0xFF)
    --print("SB", addr, base, v)
    oku:put_memory_i8(addr, v)
  elseif i.s.funct3 == 1 then
    -- sh
    local v = bit.band(v2, 0xFFFF)
    --print("SH", addr, base, v)
    oku:put_memory_i16(addr, v)
  elseif i.s.funct3 == 2 then
    -- sw
    local v = bit.band(v2, 0xFFFFFFFF)
    --print("SW", addr, base, v)
    oku:put_memory_i32(addr, v)
  elseif i.s.funct3 == 3 then
    -- sd
    local v = bit.band(v2, 0xFFFFFFFFFFFFFFFF)
    --print("SD", addr, base, v)
    oku:put_memory_i64(addr, v)
  else
    error("invalid store instruction; funct3:" .. i.s.funct3)
  end
  return true, nil
end

-- Arithmetic with Register
function isa.ins.arith(i, _npc, oku)
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
      isa.w_xr_i32(rd, bit.lshift(v1, bit.band(v2, 0x1F)), oku)
    elseif i.r.funct3 == 2 then
      -- slt
      if v1 < v2 then
        isa.w_xr_i32(rd, 1, oku)
      else
        isa.w_xr_i32(rd, 0, oku)
      end
    elseif i.r.funct3 == 3 then
      -- sltu
      if v1u < v2u then
        isa.w_xr_i32(rd, 1, oku)
      else
        isa.w_xr_i32(rd, 0, oku)
      end
    elseif i.r.funct3 == 4 then
      -- xor
      isa.w_xr_i32(rd, bit.bxor(v1, v2), oku)
    elseif i.r.funct3 == 5 then
      -- srl & sra
      if i.r.funct7 == 0 then
        isa.w_xr_i32(rd, bit.rshift(v1, bit.band(v2, 0x1F)), oku)
      elseif i.r.funct7 == 32 then
        error("unimplemented: sra")
      end
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
  return true, nil
end

function isa.ins.lui(i, _npc, oku)
  isa:nload_u_ins()
  local rd = i.u.rd
  local imm20 = i.u.imm20
  local lui = isa:encode_syn_lui(imm20, 0).i32
  --print("LUI", isa.REGISTER_NAME[rd], lui)
  isa.w_xr_i32(rd, lui, oku)
  return true, nil
end

function isa.ins.branch(i, npc, oku)
  isa:nload_b_ins()
  local offset = i.b.s_imm13
  local new_pc = npc + offset
  local v1 = isa.xr_i32(i.b.rs1, oku)
  local v1u = isa.xr_u32(i.b.rs1, oku)
  local v2 = isa.xr_i32(i.b.rs2, oku)
  local v2u = isa.xr_u32(i.b.rs2, oku)

  if i.b.funct3 == 0 then
    -- beq
    if v1 == v2 then
      --print("BEQ", format_hex(8, new_pc))
      return attempt_jump(new_pc, oku)
    end
    return true, nil
  elseif i.b.funct3 == 1 then
    -- bne
    if v1 ~= v2 then
      --print("BNE", format_hex(8, new_pc))
      return attempt_jump(new_pc, oku)
    end
    return true, nil
  elseif i.b.funct3 == 4 then
    -- blt
    if v1 < v2 then
      --print("BLT", format_hex(8, new_pc))
      return attempt_jump(new_pc, oku)
    end
    return true, nil
  elseif i.b.funct3 == 5 then
    -- bge
    if v1 >= v2 then
      --print("BGE", format_hex(8, new_pc))
      return attempt_jump(new_pc, oku)
    end
    return true, nil
  elseif i.b.funct3 == 6 then
    -- bltu
    if v1u < v2u then
      --print("BLTU", format_hex(8, new_pc))
      return attempt_jump(new_pc, oku)
    end
    return true, nil
  elseif i.b.funct3 == 7 then
    -- bgeu
    if v1u >= v2u then
      --print("BGEU", format_hex(8, new_pc))
      return attempt_jump(new_pc, oku)
    end
    return true, nil
  else
    error("invalid branch instruction; funct3:" .. i.b.funct3)
  end
end

function isa.ins.jalr(i, npc, oku)
  isa:nload_i_ins()
  local rd = i.i.rd
  local rs1 = i.i.rs1
  local imm12 = i.i.s_imm12
  local funct3 = i.i.funct3

  if funct3 == 0x0 then
    -- 0 lsb by shifting right and then back to the left
    local offset = bit.lshift(bit.rshift(isa.xr_i32(rs1, oku) + imm12, 1), 1)
    if rs1 == 0x1 then
      --print("RET", isa.REGISTER_NAME[rd], offset)
    else
      --print("JALR", isa.REGISTER_NAME[rd], offset)
    end
    isa.w_xr_i32(rd, npc + 4, oku)
    return attempt_jump(npc + offset, oku)
  else
    error("invalid 'jalr' instruction (got funct3:" .. funct3 .. ")")
  end
end

function isa.ins.jal(i, npc, oku)
  isa:nload_j_ins()
  local rd = i.j.rd
  local offset = i.j.s_imm21

  --print("JAL", isa.REGISTER_NAME[rd], format_hex(8, oku.registers.pc.u32))
  isa.w_xr_u32(rd, npc + 4, oku)
  return attempt_jump(npc + offset, oku)
end

function isa.ins.system(i, _npc, oku)
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

function isa.step_ins(oku, ins)
  isa:load_head(ins)

  local npc = oku.registers.pc.u32
  if isa._native.u32 == 0 then
    return nil, "illegal instruction"
  else
    if isa._native.head.iflag == 0x3 then
      oku.registers.pc.u32 = npc + 4
      local ins_name = assert(isa.OPCODE_TO_INS[isa._native.head.opcode])
      --print(oku.exec_counter .. " | PC:" .. format_hex(8, npc) .. " STEP:" .. ins_name .. "(" .. format_hex(8, isa._native.u32) .. ")")
      return isa.ins[ins_name](isa._native, npc, oku)
    else
      error(oku.exec_counter .. " | PC:" .. format_hex(8, npc) .." Bad instruction " .. format_hex(8, isa._native.u32))
      -- TODO: error
    end
  end
end

function isa.init(oku, assigns)
  --
end

function isa.dispose(oku, assigns)
  --
end

function isa.reset(oku, assigns)
  --
end

function isa.step(oku, assigns)
  oku.exec_counter = oku.exec_counter + 1
  assert(oku.registers.x[0].i32 == 0, "expected 0 register to be well 0 got:" .. oku.registers.x[0].i32)

  return isa.step_ins(oku, oku:get_memory_i32(oku.registers.pc.u32))
end

local ByteBuf = yatm_core.ByteBuf

function isa.bindump(oku, stream, assigns)
  local bytes_written = 0
  local bw, err = ByteBuf.w_u32(stream, 0)
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
  assert(version == 0)
  return bytes_read
end

yatm_oku.OKU.isa.RISCV = isa
