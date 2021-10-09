/*


 */
#include <stdint.h>
#include "bit16.h"

#define OK_CODE 0
#define INVALID_CODE 1
#define SEGFAULT_CODE -1
#define HALT_CODE 4
#define HANG_CODE 5

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
