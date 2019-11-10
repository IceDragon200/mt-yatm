#ifndef OKU_6502_COMMON_H_
#define OKU_6502_COMMON_H_

#include <stdint.h>

#include "bit8.h"

#define VERSION_MAJOR 0
#define VERSION_MINOR 1
#define VERSION_TEENY 0

#define OK_CODE 0
#define INVALID_CODE 1
#define HALT_CODE 4
#define HANG_CODE 5
#define STARTUP_CODE 7
#define SEGFAULT_CODE 127

// The CPU is in it's reset sequence, the upper nibble of the state is what 'stage' the reset sequence is in
#define CPU_STATE_RESET 1
// The CPU is in it's normal running state
#define CPU_STATE_RUN 2
// The CPU is in a hang state, any step will immediately return a HANG_CODE
#define CPU_STATE_HANG 3

#define NMI_VECTOR_PTR 0xFFFA
#define RESET_VECTOR_PTR 0xFFFC
#define IRQ_VECTOR_PTR 0xFFFE
#define BREAK_VECTOR_PTR 0xFFFE

struct oku_6502_chip
{
  uint16_t ab;        // Address Bus
  uint16_t pc;        // Program Counter
  uint8_t sp;         // Stack Pointer
  uint8_t ir;         // Instruction Register
  int8_t a;           // Accumulator
  int8_t x;           // X
  int8_t y;           // Y
  int8_t sr;          // Status Register [NV-BDIZC]
  // Ends the 6502 Registers

  // 0000 (state param) 0000 (state code)
  int8_t state; // Not apart of the 6502,
                // this is here to define different states the CPU is in for the step function

  uint32_t cycles; // Cycles never go backwards do they?
  int32_t operand; // Any data we need to store for a bit
};

#define CARRY_FLAG(sr) (RBIT0(sr))
#define ZERO_FLAG(sr) (RBIT1(sr))
#define IRQ_DISABLE_FLAG(sr) (RBIT2(sr))
#define DECIMAL_MODE_FLAG(sr) (RBIT3(sr))
#define BREAK_COMMAND_FLAG(sr) (RBIT4(sr))
#define OVERFLOW_FLAG(sr) (RBIT6(sr))
#define NEGATIVE_FLAG(sr) (RBIT7(sr))

#define SET_CARRY_FLAG(sr, value) (WBIT0(sr, value))
#define SET_ZERO_FLAG(sr, value) (WBIT1(sr, value))
#define SET_IRQ_DISABLE_FLAG(sr, value) (WBIT2(sr, value))
#define SET_DECIMAL_MODE_FLAG(sr, value) (WBIT3(sr, value))
#define SET_BREAK_COMMAND_FLAG(sr, value) (WBIT4(sr, value))
#define SET_OVERFLOW_FLAG(sr, value) (WBIT6(sr, value))
#define SET_NEGATIVE_FLAG(sr, value) (WBIT7(sr, value))

#endif
