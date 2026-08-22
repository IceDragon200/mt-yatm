/*

  OKU SM8 (Stack Machine 8-bit with 16 bit addressing)

  An execution abstraction layer made to be easily resumable.

 */
#include <stdint.h>

#include "bit_helpers.h"

#define OKU_SM_OP_NOOP 0x00
#define OKU_SM_OP_LOAD8 0x85
#define OKU_SM_OP_STORE8 0x86


#define OKU_SM_STATUS_OK 0x00
#define OKU_SM_STATUS_INTERRUPT 0x03
#define OKU_SM_STATUS_STACK_EMPTY 0x01
#define OKU_SM_STATUS_STACK_FULL 0x10
#define OKU_SM_STATUS_SEGFAULT 0x7F

// If the memory is to be read, return 0 instead
#define OKU_SM_MF_READ_PROTECT(flags) RBIT0(flags)
// If the memory is to be written, no-op instead
#define OKU_SM_MF_WRITE_PROTECT(flags) RBIT1(flags)
// If the memory is to be used as an opcode, HANG instead
#define OKU_SM_MF_EXECUTE_PROTECT(flags) RBIT2(flags)
// If the memory is to be read/write/execute interrupt stack machine and let the caller handle it before resuming execution
#define OKU_SM_MF_INTERRUPT(flags) RBIT3(flags)


#define OKU_SM_RW_NOP 0
#define OKU_SM_RW_READ 1
#define OKU_SM_RW_WRITE 2

struct oku_sm8_state
{
  // Stack pointer
  uint32_t sp;
  // And bunch of opcodes or params
  uint8_t stack[0x100];

  uint32_t memory_size; // Size in bytes
  // Flags: ----IXWR (|-|-|-|-|Interrupt|eXecute|Write|Read|)
  uint8_t* memory_flags; // same size as memory
  char* memory; // Actual memory, in bytes

  uint8_t opcode;
  int32_t d; // DATA - can be any form of data, so an int32 is just for that
  uint32_t df; // DATA-FLAGs

  uint16_t addr;
  int8_t rw; // See OKU_SM_RW_*
  int8_t _padding;
};

static void oku_sm8_state_init(struct oku_sm8_state* sm_state)
{
  // Initialize the stack
  sm_state->sp = 0xFF;
  for (uint32_t i = 0; i < 0x100; ++i)
  {
    sm_state->stack[i] = 0;
  }

  // Initialize the memory to null
  sm_state->memory_size = 0;
  sm_state->memory_flags = 0;
  sm_state->memory = 0;
  sm_state->opcode = 0;
  sm_state->d = 0;
  sm_state->df = 0;
}

static void oku_sm8_stack_push(struct oku_sm8_state* sm_state, uint8_t value, int* status)
{
  if (sm_state->sp == 0)
  {
    *status = OKU_SM_STATUS_STACK_FULL;
    return;
  }
  *status = OKU_SM_STATUS_OK;
  sm_state->stack[sm_state->sp] = value;
  sm_state->sp -= 1;
}

static uint8_t oku_sm8_stack_pop(struct oku_sm8_state* sm_state, int* status)
{
  if (sm_state->sp == 255)
  {
    *status = OKU_SM_STATUS_STACK_EMPTY;
    return 0;
  }
  *status = OKU_SM_STATUS_OK;
  sm_state->sp += 1;
  return sm_state->stack[sm_state->sp];
}

static int oku_sm8_state_step(struct oku_sm8_state* sm_state)
{
  int status = OKU_SM_STATUS_OK;
  uint8_t value = oku_sm8_stack_pop(sm_state, &status);
  if (status != OKU_SM_STATUS_OK)
  {
    return status;
  }

  sm_state->opcode = value;

  switch (value)
  {
    case OKU_SM_OP_NOOP:
    {
      sm_state->rw = OKU_SM_RW_NOP;
      sm_state->addr = 0;
      sm_state->df = 0;
      sm_state->d = 0;
      status = OKU_SM_STATUS_OK;
    } break;

    // L8 | hi | lo
    case OKU_SM_OP_LOAD8:
    {
      uint8_t hi = oku_sm8_stack_pop(sm_state, &status);
      uint8_t lo = oku_sm8_stack_pop(sm_state, &status);
      uint16_t addr = (uint16_t)(((uint16_t)hi << 8) | lo);

      sm_state->rw = OKU_SM_RW_READ;
      sm_state->addr = addr;

      if (sm_state->addr > sm_state->memory_size)
      {
        status = OKU_SM_STATUS_SEGFAULT;
      }
      else
      {
        if (sm_state->memory_flags != 0)
        {
          sm_state->df = sm_state->memory_flags[sm_state->addr];
          if (OKU_SM_MF_READ_PROTECT(sm_state->df) == 1)
          {
            // If read protected, always set the data to 0
            sm_state->d = 0;
          }
          else
          {
            // Otherwise, extract the data from the memory
            sm_state->d = sm_state->memory[sm_state->addr];
          }

          if (OKU_SM_MF_INTERRUPT(sm_state->df) == 1)
          {
            status = OKU_SM_STATUS_INTERRUPT;
          }
          else
          {
            status = OKU_SM_STATUS_OK;
          }
        }
        else
        {
          sm_state->df = 0;
          sm_state->d = sm_state->memory[sm_state->addr];
          status = OKU_SM_STATUS_OK;
        }
      }
      //
    } break;

    // S8 | hi | lo | value
    case OKU_SM_OP_STORE8:
    {
      uint8_t hi = oku_sm8_stack_pop(sm_state, &status);
      uint8_t lo = oku_sm8_stack_pop(sm_state, &status);
      uint16_t addr = (uint16_t)(((uint16_t)hi << 8) | lo);

      sm_state->rw = OKU_SM_RW_WRITE;
      sm_state->addr = addr;
      sm_state->d = oku_sm8_stack_pop(sm_state, &status);

      if (sm_state->addr > sm_state->memory_size)
      {
        status = OKU_SM_STATUS_SEGFAULT;
      }
      else
      {
        if (sm_state->memory_flags != 0)
        {
          sm_state->df = sm_state->memory_flags[sm_state->addr];
          if (OKU_SM_MF_WRITE_PROTECT(sm_state->df) == 1)
          {
            // If write protected, don't do anything
          }
          else
          {
            // Otherwise, change the contents of memory
            sm_state->memory[sm_state->addr] = sm_state->d;
          }

          if (OKU_SM_MF_INTERRUPT(sm_state->df) == 1)
          {
            status = OKU_SM_STATUS_INTERRUPT;
          }
          else
          {
            status = OKU_SM_STATUS_OK;
          }
        }
        else
        {
          sm_state->df = 0;
          sm_state->memory[addr] = sm_state->d;
          status = OKU_SM_STATUS_OK;
        }
      }

    } break;
  }
  return status;
}
