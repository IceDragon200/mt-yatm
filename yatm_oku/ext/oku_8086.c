/*


 */
#include <stdint.h>

#define OK_CODE 0
#define INVALID_CODE 1
#define SEGFAULT_CODE -1
#define HALT_CODE 4
#define HANG_CODE 5

// Bitwise helpers
#define BIT0 0x1
#define BIT1 0x2
#define BIT2 0x4
#define BIT3 0x8
#define BIT4 0x10
#define BIT5 0x20
#define BIT6 0x40
#define BIT7 0x80
#define BIT8 0x100
#define BIT9 0x200
#define BIT10 0x400
#define BIT11 0x800
#define BIT12 0x1000
#define BIT13 0x2000
#define BIT14 0x4000
#define BIT15 0x8000

#define RBIT0(value) ((value) & 0x1)
#define RBIT1(value) (((value) >> 1) & 0x1)
#define RBIT2(value) (((value) >> 2) & 0x1)
#define RBIT3(value) (((value) >> 3) & 0x1)
#define RBIT4(value) (((value) >> 4) & 0x1)
#define RBIT5(value) (((value) >> 5) & 0x1)
#define RBIT6(value) (((value) >> 6) & 0x1)
#define RBIT7(value) (((value) >> 7) & 0x1)
#define RBIT8(value) (((value) >> 8) & 0x1)
#define RBIT9(value) (((value) >> 9) & 0x1)
#define RBIT10(value) (((value) >> 10) & 0x1)
#define RBIT11(value) (((value) >> 11) & 0x1)
#define RBIT12(value) (((value) >> 12) & 0x1)
#define RBIT13(value) (((value) >> 13) & 0x1)
#define RBIT14(value) (((value) >> 14) & 0x1)
#define RBIT15(value) (((value) >> 15) & 0x1)

#define WBIT0(base, value) (((base) & (0xFFFF ^ BIT0)) | ((value) & 0x1))
#define WBIT1(base, value) (((base) & (0xFFFF ^ BIT1)) | (((value) & 0x1) << 1))
#define WBIT2(base, value) (((base) & (0xFFFF ^ BIT2)) | (((value) & 0x1) << 2))
#define WBIT3(base, value) (((base) & (0xFFFF ^ BIT3)) | (((value) & 0x1) << 3))
#define WBIT4(base, value) (((base) & (0xFFFF ^ BIT4)) | (((value) & 0x1) << 4))
#define WBIT5(base, value) (((base) & (0xFFFF ^ BIT5)) | (((value) & 0x1) << 5))
#define WBIT6(base, value) (((base) & (0xFFFF ^ BIT6)) | (((value) & 0x1) << 6))
#define WBIT7(base, value) (((base) & (0xFFFF ^ BIT7)) | (((value) & 0x1) << 7))
#define WBIT8(base, value) (((base) & (0xFFFF ^ BIT8)) | (((value) & 0x1) << 8))
#define WBIT9(base, value) (((base) & (0xFFFF ^ BIT9)) | (((value) & 0x1) << 9))
#define WBIT10(base, value) (((base) & (0xFFFF ^ BIT10)) | (((value) & 0x1) << 10))
#define WBIT11(base, value) (((base) & (0xFFFF ^ BIT11)) | (((value) & 0x1) << 11))
#define WBIT12(base, value) (((base) & (0xFFFF ^ BIT12)) | (((value) & 0x1) << 12))
#define WBIT13(base, value) (((base) & (0xFFFF ^ BIT13)) | (((value) & 0x1) << 13))
#define WBIT14(base, value) (((base) & (0xFFFF ^ BIT14)) | (((value) & 0x1) << 14))
#define WBIT15(base, value) (((base) & (0xFFFF ^ BIT15)) | (((value) & 0x1) << 15))

struct oku_8086_chip
{
  // 64 bit block
  union {
    struct {
      int8_t al;
      int8_t ah;
    };
    int16_t ax;
  };
  union {
    struct {
      int8_t bl;
      int8_t bh;
    };
    int16_t bx;
  };
  union {
    struct {
      int8_t cl;
      int8_t ch;
    };
    int16_t cx;
  };
  union {
    struct {
      int8_t dl;
      int8_t dh;
    };
    int16_t dx;
  };
  // 64 bit block
  int16_t cs;
  int16_t ds;
  int16_t ss;
  int16_t es;
  // 64 bit block
  int16_t bp;
  int16_t sp;
  int16_t si;
  int16_t di;
  // 64 bit block
  uint16_t ip;        // Program Counter
  int16_t flags;

  uint32_t cycles; // Cycles never go backwards do they?
};

#define CARRY_FLAG(flags) (RBIT0(flags))
#define PARITY_FLAG(flags) (RBIT2(flags))
#define AUX_CARRY_FLAG(flags) (RBIT4(flags))
#define ZERO_FLAG(flags) (RBIT6(flags))
#define SIGN_FLAG(flags) (RBIT7(flags))
#define TRAP_FLAG(flags) (RBIT8(flags))
#define INTERRUPT_FLAG(flags) (RBIT9(flags))
#define DIRECTION_FLAG(flags) (RBIT10(flags))
#define OVERFLOW_FLAG(flags) (RBIT11(flags))

#define SET_CARRY_FLAG(flags, value) (WBIT0(flags, value))
#define SET_PARITY_FLAG(flags, value) (WBIT2(flags, value))
#define SET_AUX_CARRY_FLAG(flags, value) (WBIT4(flags, value))
#define SET_ZERO_FLAG(flags, value) (WBIT6(flags, value))
#define SET_SIGN_FLAG(flags, value) (WBIT7(flags, value))
#define SET_TRAP_FLAG(flags, value) (WBIT8(flags, value))
#define SET_INTERRUPT_FLAG(flags, value) (WBIT9(flags, value))
#define SET_DIRECTION_FLAG(flags, value) (WBIT10(flags, value))
#define SET_OVERFLOW_FLAG(flags, value) (WBIT11(flags, value))

extern void oku_8086_chip_init(struct oku_8086_chip* chip)
{
  // General Registers
  chip->ax = 0;
  chip->bx = 0;
  chip->cx = 0;
  chip->dx = 0;
  // Segment Registers
  chip->cs = 0;
  chip->ds = 0;
  chip->ss = 0;
  chip->es = 0;
  // Pointers
  chip->bp = 0;
  chip->sp = 0;
  chip->si = 0;
  chip->di = 0;
  // Program Counter
  chip->ip = 0;
  // Flags
  chip->flags = 0;

  // Misc.
  chip->cycles = 0;
}

extern int oku_8086_chip_step(struct oku_8086_chip* chip, int32_t mem_size, char* mem)
{
  int status = INVALID_CODE;
  // TODO
  return status;
}
