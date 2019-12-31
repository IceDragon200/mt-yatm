/*

  Implementation of the MOS 6502 using the OKU SM8 stack machine.

  This implementation allows interrupts between opcode calls, which allows
  changing memory and data sections to fit execution needs.

  Let's say you want something to react to a change in memory at a specific location:
  Say a data channel, you can set the memory flag to interrupt, and anytime that location
  is to be read or written to, the execution stops and allows control over the state.

  But if you don't want an interruptable implementation the good old oku_6502 is available.

 */
#include "oku_6502_common.h"

#include "oku_sm8.c"

struct oku_sm6502_state
{
  struct oku_sm8_state sm8;
  struct oku_6502_chip chip;
  uint32_t memory_size;
  uint8_t* memory_flags;
  char* memory;
};

extern void oku_sm6502_chip_init(struct oku_6502_chip* chip)
{
  chip->ab = 0;
  chip->pc = 0;
  chip->sp = 0;
  chip->ir = 0;
  chip->a = 0;
  chip->x = 0;
  chip->y = 0;
  chip->sr = 0;
  chip->state = 0;
  chip->cycles = 0;
  chip->operand = 0;
}

extern void oku_sm6502_state_init(struct oku_sm6502_state* state)
{
  oku_sm8_state_init(&state->sm8);
  oku_sm6502_chip_init(&state->chip);
  state->memory_size = 0;
  state->memory = 0;
  state->memory_flags = 0;
}

extern void oku_sm6502_state_refresh(struct oku_sm6502_state* state)
{
  state->sm8->memory_size = state->memory_size;
  state->sm8->memory = state->memory;
  state->sm8->memory_flags = state->memory_flags;
}

extern int oku_sm6502_chip_startup(struct oku_sm6502_state* state)
{

}

extern int oku_sm6502_chip_fex(struct oku_sm6502_state* state)
{

}

extern int oku_sm6502_state_step(struct oku_sm6502_state* state)
{
  switch (chip->state & 0xF)
  {
    case CPU_STATE_RESET:
      return oku_sm6502_chip_startup(chip, mem_size, mem);

    case CPU_STATE_RUN:
      return oku_sm6502_chip_fex(chip, mem_size, mem);

    case CPU_STATE_HANG:
      return HANG_CODE;

    default:
      return INVALID_CODE;
  }
}
