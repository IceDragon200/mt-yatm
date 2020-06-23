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

ffi.cdef[[
struct yatm_oku_registers32 {
  union yatm_oku_register32 x[32];
  union yatm_oku_register32 pc;
};
]]

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
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint32_t rest : 25;
  } head;
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t rd : 5;
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    uint8_t rs2 : 5;
    uint8_t funct7 : 7;
  } r;
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
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t imm0 : 5;
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    uint8_t rs2 : 5;
    uint8_t imm1 : 7;
  } s;
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    uint8_t rd : 5;
    uint32_t imm : 20;
  } u;
  struct {
    uint8_t iflag : 2;
    uint8_t opcode : 5;
    union {
      struct {
        uint8_t imm0 : 1;
        uint8_t imm1 : 4;
      };
      uint8_t bimm12lo : 5;
    };
    uint8_t funct3 : 3;
    uint8_t rs1 : 5;
    uint8_t rs2 : 5;
    union {
      struct {
        uint8_t imm2 : 6;
        uint8_t imm3 : 1;
      };
      uint8_t bimm12hi : 7;
    };
  } b;
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
};
]]
