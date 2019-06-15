local ffi = assert(yatm_oku.ffi)

ffi.cdef[[
union yatm_oku_rv32i_ins {
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
        int8_t  imm0 : 8;
        int8_t  imm1 : 1;
        int16_t imm2 : 10;
        int8_t  imm3 : 1;
      };
    };
  };
};
]]

yatm_oku.OKU.isa.RISCV = true
