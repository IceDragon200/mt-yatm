/*

// Copied most of the implementation from this, with a few adjustments
http://oric.free.fr/microtan/microtan_java.html

// Reference for instruction set
https://www.masswerk.at/6502/6502_instruction_set.html

// Reference for startup sequence and other things
https://www.pagetable.com/?p=410

// Copied here for reference

Address Modes:
A       ....  Accumulator           OPC A         operand is AC (implied single byte instruction)
abs     ....  absolute              OPC $LLHH     operand is address $HHLL *
abs,X   ....  absolute, X-indexed   OPC $LLHH,X   operand is address; effective address is address incremented by X with carry **
abs,Y   ....  absolute, Y-indexed   OPC $LLHH,Y   operand is address; effective address is address incremented by Y with carry **
#       ....  immediate             OPC #$BB      operand is byte BB
impl    ....  implied               OPC           operand implied
ind     ....  indirect              OPC ($LLHH)   operand is address; effective address is contents of word at address: C.w($HHLL)
X,ind   ....  X-indexed, indirect   OPC ($LL,X)   operand is zeropage address; effective address is word in (LL + X, LL + X + 1), inc. without carry: C.w($00LL + X)
ind,Y   ....  indirect, Y-indexed   OPC ($LL),Y   operand is zeropage address; effective address is word in (LL, LL + 1) incremented by Y with carry: C.w($00LL) + Y
rel     ....  relative              OPC $BB       branch target is PC + signed offset BB ***
zpg     ....  zeropage              OPC $LL       operand is zeropage address (hi-byte is zero, address = $00LL)
zpg,X   ....  zeropage, X-indexed   OPC $LL,X     operand is zeropage address; effective address is address incremented by X without carry **
zpg,Y   ....  zeropage, Y-indexed   OPC $LL,Y     operand is zeropage address; effective address is address incremented by Y without carry **

*   16-bit address words are little endian, lo(w)-byte first, followed by the hi(gh)-byte.
(An assembler will use a human readable, big-endian notation as in $HHLL.)

**  The available 16-bit address space is conceived as consisting of pages of 256 bytes each, with
address hi-bytes represententing the page index. An increment with carry may affect the hi-byte
and may thus result in a crossing of page boundaries, adding an extra cycle to the execution.
Increments without carry do not affect the hi-byte of an address and no page transitions do occur.
Generally, increments of 16-bit addresses include a carry, increments of zeropage addresses don't.
Notably this is not related in any way to the state of the carry bit of the accumulator.

*** Branch offsets are signed 8-bit values, -128 ... +127, negative offsets in two's complement.
Page transitions may occur and add an extra cycle to the exucution.

*/
#include "oku_6502_common.h"

extern int8_t oku_6502_mem_read_i8(int32_t mem_size, char* mem, int32_t index, int* status)
{
  if (index >= mem_size || index < 0)
  {
    // Tried to read outside of the memory range, set the status to SEGFAULT
    // i.e. you tried to read outside of the allowed memory
    *status = SEGFAULT_CODE;
    return 0;
  }
  // otherwise it's a-ok!
  *status = OK_CODE;
  return (int8_t)mem[index];
}

extern void oku_6502_mem_write_i8(int32_t mem_size, char* mem, int32_t index, int8_t value, int* status)
{
  if (index >= mem_size || index < 0)
  {
    // Tried to read outside of the memory range, set the status to SEGFAULT
    // i.e. you tried to read outside of the allowed memory
    *status = SEGFAULT_CODE;
    return;
  }
  // otherwise it's a-ok!
  *status = OK_CODE;
  mem[index] = value;
}

extern int16_t oku_6502_mem_read_i16(int32_t mem_size, char* mem, int32_t index, int* status)
{
  int8_t lo;
  int8_t hi;
  // index is always byte-aligned, so in order to achieve a 16-bit read, read 2 8-bits.
  lo = oku_6502_mem_read_i8(mem_size, mem, index, status);
  if (*status != OK_CODE)
  {
    // Yikes
    return 0;
  }
  hi = oku_6502_mem_read_i8(mem_size, mem, index + 1, status);
  if (*status != OK_CODE)
  {
    // Yikes - again
    return 0;
  }
  // Whew, we're good!
  return (((int16_t)hi) << 8) | ((int16_t)lo);
}

extern int8_t oku_6502_chip_read_mem_i8(struct oku_6502_chip* chip, int32_t index, int32_t mem_size, char* mem, int* status)
{
  chip->cycles += 1;
  return oku_6502_mem_read_i8(mem_size, mem, index, status);
}

extern void oku_6502_chip_write_mem_i8(struct oku_6502_chip* chip, int32_t index, int8_t value, int32_t mem_size, char* mem, int* status)
{
  chip->cycles += 1;
  oku_6502_mem_write_i8(mem_size, mem, index, value, status);
}

// PC Counter memory read and write helpers
extern int8_t oku_6502_read_pc_mem_i8(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  // Reads the value at the program counter
  return oku_6502_chip_read_mem_i8(chip, chip->pc, mem_size, mem, status);
}

extern void oku_6502_write_pc_mem_i8(struct oku_6502_chip* chip, int8_t value, int32_t mem_size, char* mem, int* status)
{
  // Reads the value at the program counter
  oku_6502_chip_write_mem_i8(chip, chip->pc, value, mem_size, mem, status);
}

extern int16_t oku_6502_read_pc_mem_i16(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  // Reads the value at the program counter
  chip->cycles += 2; // we're reading twice (whether or not it actually happened)
  return oku_6502_mem_read_i16(mem_size, mem, chip->pc, status);
}

//
// Stack
//
extern void oku_6502_push_stack(struct oku_6502_chip* chip, int8_t value, int32_t mem_size, char* mem, int* status)
{
  oku_6502_chip_write_mem_i8(chip, chip->sp + 0x100, value, mem_size, mem, status);
  chip->sp = (chip->sp - 1) & 0xFF;
}

extern int8_t oku_6502_read_stack(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  return oku_6502_chip_read_mem_i8(chip, chip->sp + 0x100, mem_size, mem, status);
}

extern int8_t oku_6502_pop_stack(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sp = (chip->sp + 1) & 0xFF;
  return oku_6502_chip_read_mem_i8(chip, chip->sp + 0x100, mem_size, mem, status);
}

extern void oku_6502_push_pc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t hi = (chip->pc >> 8) & 0xFF;
  int8_t lo = chip->pc & 0xFF;
  oku_6502_push_stack(chip, hi, mem_size, mem, status);
  oku_6502_push_stack(chip, lo, mem_size, mem, status);
}

extern void oku_6502_pop_pc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t lo = (int16_t)oku_6502_pop_stack(chip, mem_size, mem, status);
  int16_t hi = (int16_t)oku_6502_pop_stack(chip, mem_size, mem, status);

  chip->pc = (hi << 8) | lo;
}

//
// opr_* operand functions
//
static void opr_implied_i8(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  // Just read an i8 value, forcing the cycles to increase, and then discard it.
  oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
}

static void opr_immediate_i8(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->operand = chip->pc;
  chip->pc += 1;
}

static void opr_absolute_i16(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->operand = oku_6502_read_pc_mem_i16(chip, mem_size, mem, status);
  chip->pc += 2;
}

static void opr_absolute_i16x(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t ol = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;
  int16_t oh = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  ol += chip->x;

  // dirty
  chip->operand = (int32_t)((oh << 8) + ol);

  if (ol >= 0x100)
  {
    // really only to trigger the cycles increment
    oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  }

  // clean
  chip->operand &= 0xFFFF;
}

static void opr_absolute_i16y(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t ol = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;
  int16_t oh = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  oh <<= 8;

  ol += chip->y;

  // dirty
  chip->operand = (int32_t)(oh + ol);

  if (ol >= 0x100)
  {
    // really only to trigger the cycles increment
    oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  }

  // clean
  chip->operand &= 0xFFFF;
}

static void opr_indirect_i16(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t al = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;
  int16_t ah = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  ah <<= 8;

  int16_t a = ah | al;

  int16_t ol = (int16_t)oku_6502_chip_read_mem_i8(chip, a, mem_size, mem, status);
  int16_t oh = (int16_t)oku_6502_chip_read_mem_i8(chip, a + 1, mem_size, mem, status);

  chip->operand = (int32_t)((oh << 8) + ol) & 0xFFFF;
}

static void opr_indirect_i16x(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t ptr = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  ptr = (ptr + chip->x) & 0xFF;

  int16_t ol = (int16_t)oku_6502_chip_read_mem_i8(chip, ptr, mem_size, mem, status);
  int16_t oh = (int16_t)oku_6502_chip_read_mem_i8(chip, (ptr + 1) & 0xFF, mem_size, mem, status);
  oh <<= 8;

  chip->operand = (int32_t)(oh + ol) & 0xFFFF;
}

static void opr_indirect_i16y(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t ptr = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  int16_t ol = (int16_t)oku_6502_chip_read_mem_i8(chip, ptr, mem_size, mem, status);
  ol += chip->y;

  int16_t oh = (int16_t)oku_6502_chip_read_mem_i8(chip, (ptr + 1) & 0xFF, mem_size, mem, status);
  oh <<= 8;

  if (ol > 0x100)
  {
    oku_6502_chip_read_mem_i8(chip, oh + (ol & 0xFF), mem_size, mem, status);
  }

  chip->operand = (int32_t)(oh + ol) & 0xFFFF;
}

static void opr_relative_i16(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t offset = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  chip->operand = (int32_t)(chip->pc + offset) & 0xFFFF;
}

static void opr_zeropage_i16(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t ptr = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  chip->operand = (int32_t)ptr;
}

static void opr_zeropage_i16x(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t ptr = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  chip->operand = (int32_t)(ptr + chip->x) & 0xFF;
}

static void opr_zeropage_i16y(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t ptr = (int16_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;

  chip->operand = (int32_t)(ptr + chip->y) & 0xFF;
}

//
// Flags
//
static inline void set_carry_flag(struct oku_6502_chip* chip, int32_t value)
{
  chip->sr = SET_CARRY_FLAG(chip->sr, (value & 0x100) >> 8);
}

static inline void set_borrow_flag(struct oku_6502_chip* chip, int32_t value)
{
  chip->sr = SET_CARRY_FLAG(chip->sr, ((value & 0x100) >> 8) ^ 1);
}

static inline void set_negative_flag(struct oku_6502_chip* chip, int32_t value)
{
  chip->sr = SET_NEGATIVE_FLAG(chip->sr, value < 0 ? 1 : 0);
}

static inline void set_zero_flag(struct oku_6502_chip* chip, int32_t value)
{
  chip->sr = SET_ZERO_FLAG(chip->sr, value == 0 ? 1 : 0);
}

//
// Execute Operations
//
static void exec_adc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t op1 = (int16_t)chip->a;
  int16_t op2 = (int16_t)oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  int16_t value = op1 + op2 + CARRY_FLAG(chip->sr);
  if (DECIMAL_MODE_FLAG(chip->sr) == 0)
  {
    chip->a = value & 0xFF;
    chip->sr = SET_OVERFLOW_FLAG(chip->sr, ((op1 ^ chip->a) & ~(op1 ^ op2) & 0x80) >> 7);

    set_carry_flag(chip, (int32_t)value);
    set_negative_flag(chip, (int32_t)value);
    set_zero_flag(chip, (int32_t)value);
  }
  else
  {
    // decimal mode behavior following Marko Makela's explanations
    // Stolen from a java based 6502 interpreter
    // I'll be honest, I have no idea how this works.
    int16_t tmp;
    chip->sr = SET_ZERO_FLAG(chip->sr, (value & 0xFF) == 0 ? 1 : 0);

    tmp = (op1 & 0x0F) + (op2 & 0x0F) + CARRY_FLAG(chip->sr);
    chip->a = tmp < 0x0A ? tmp : tmp + 6;

    tmp = (op1 & 0xF0) + (op2 & 0xF0) + (tmp & 0xF0);

    chip->sr = SET_NEGATIVE_FLAG(chip->sr, tmp < 0 ? 1 : 0);
    chip->sr = SET_OVERFLOW_FLAG(chip->sr, ((op1 ^ tmp) & ~(op1 ^ op2) & 0x80) >> 7);

    tmp = (chip->a & 0x0F) | (tmp < 0xA0 ? tmp : tmp + 0x60);

    chip->sr = SET_CARRY_FLAG(chip->sr, tmp > 0x100 ? 1 : 0);

    chip->a = tmp & 0xFF;
  }
}

static void exec_and(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->a &= oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  set_negative_flag(chip, (int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_asl(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t tmp = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);

  chip->sr = SET_CARRY_FLAG(chip->sr, tmp < 0 ? 1 : 0);

  tmp <<= 1;

  set_negative_flag(chip, (int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);

  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);
}

static void exec_asl_a(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t tmp = (int16_t)chip->a << 1;
  tmp &= 0xFF;

  set_carry_flag(chip, tmp);
  set_negative_flag(chip, (int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);
}

static void do_exec_branch(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);

  if ((chip->pc & 0xFF00) != (chip->operand & 0xFF00))
  {
    int32_t addr = (int32_t)((chip->pc & 0xFF00) | (chip->operand & 0xFF));
    oku_6502_chip_read_mem_i8(chip, addr, mem_size, mem, status);
  }

  chip->pc = chip->operand;
}

static void exec_bcc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  if (CARRY_FLAG(chip->sr) == 0)
  {
    do_exec_branch(chip, mem_size, mem, status);
  }
}

static void exec_bcs(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  if (CARRY_FLAG(chip->sr) != 0)
  {
    do_exec_branch(chip, mem_size, mem, status);
  }
}

static void exec_beq(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  if (ZERO_FLAG(chip->sr) == 1)
  {
    do_exec_branch(chip, mem_size, mem, status);
  }
}

static void exec_bit(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t tmp = oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);

  chip->sr = SET_OVERFLOW_FLAG(chip->sr, (tmp & 0x40) != 0 ? 1 : 0);
  set_negative_flag(chip, tmp);
  chip->sr = SET_ZERO_FLAG(chip->sr, (tmp & chip->a) == 0);
}

static void exec_bmi(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  if (NEGATIVE_FLAG(chip->sr) == 1)
  {
    do_exec_branch(chip, mem_size, mem, status);
  }
}

static void exec_bne(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  if (ZERO_FLAG(chip->sr) == 0)
  {
    do_exec_branch(chip, mem_size, mem, status);
  }
}

static void exec_bpl(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  if (NEGATIVE_FLAG(chip->sr) == 0)
  {
    do_exec_branch(chip, mem_size, mem, status);
  }
}

static void exec_php(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status);

static void exec_brk(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  oku_6502_push_pc(chip, mem_size, mem, status);
  exec_php(chip, mem_size, mem, status);

  chip->sr = SET_IRQ_DISABLE_FLAG(chip->sr, 1);
  chip->pc = oku_6502_chip_read_mem_i8(chip, 0xFFFE, mem_size, mem, status);
}

static void exec_bvc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  if (OVERFLOW_FLAG(chip->sr) == 0)
  {
    do_exec_branch(chip, mem_size, mem, status);
  }
}

static void exec_bvs(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  if (OVERFLOW_FLAG(chip->sr) != 0)
  {
    do_exec_branch(chip, mem_size, mem, status);
  }
}

static void exec_clc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sr = SET_CARRY_FLAG(chip->sr, 0);
}

static void exec_cld(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sr = SET_DECIMAL_MODE_FLAG(chip->sr, 0);
}

static void exec_cli(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sr = SET_IRQ_DISABLE_FLAG(chip->sr, 0);
}

static void exec_clv(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sr = SET_OVERFLOW_FLAG(chip->sr, 0);
}

static void exec_cmp(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t tmp = (int16_t)chip->a - (int16_t)oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  set_borrow_flag(chip, (int32_t)tmp);
  set_negative_flag(chip,(int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);
}

static void exec_cpx(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t tmp = (int16_t)chip->x - (int16_t)oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  set_borrow_flag(chip, (int32_t)tmp);
  set_negative_flag(chip,(int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);
}

static void exec_cpy(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t tmp = (int16_t)chip->y - (int16_t)oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  set_borrow_flag(chip, (int32_t)tmp);
  set_negative_flag(chip,(int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);
}

static void exec_dec(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t tmp = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  tmp = (tmp - 1) & 0xFF;

  set_negative_flag(chip,(int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);

  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);
}

static void exec_dex(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->x = (chip->x - 1) & 0xFF;

  set_negative_flag(chip,(int32_t)chip->x);
  set_zero_flag(chip, (int32_t)chip->x);
}

static void exec_dey(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->y = (chip->y - 1) & 0xFF;

  set_negative_flag(chip,(int32_t)chip->y);
  set_zero_flag(chip, (int32_t)chip->y);
}

static void exec_eor(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->a ^= oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  set_negative_flag(chip,(int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_inc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t tmp = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  tmp = (tmp + 1) & 0xFF;

  set_negative_flag(chip,(int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);

  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);
}

static void exec_inx(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->x = (chip->x + 1) & 0xFF;

  set_negative_flag(chip,(int32_t)chip->x);
  set_zero_flag(chip, (int32_t)chip->x);
}

static void exec_iny(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->y = (chip->y + 1) & 0xFF;

  set_negative_flag(chip,(int32_t)chip->y);
  set_zero_flag(chip, (int32_t)chip->y);
}

static void exec_jmp(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->pc = chip->operand;
}

static void exec_jsr(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t lo = oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
  chip->pc += 1;
  oku_6502_chip_read_mem_i8(chip, chip->sp + 0x100, mem_size, mem, status);
  oku_6502_push_pc(chip, mem_size, mem, status);

  int8_t hi = oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);

  chip->pc = (hi << 8) + lo;
}

static void exec_lda(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t value = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  chip->a = value;

  set_negative_flag(chip,(int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_ldx(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t value = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  chip->x = value;

  set_negative_flag(chip,(int32_t)chip->x);
  set_zero_flag(chip, (int32_t)chip->x);
}

static void exec_ldy(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t value = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  chip->y = value;

  set_negative_flag(chip,(int32_t)chip->y);
  set_zero_flag(chip, (int32_t)chip->y);
}

static void exec_lsr(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t tmp = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);

  chip->sr = SET_CARRY_FLAG(chip->sr, tmp & 1);

  tmp >>= 1;

  set_negative_flag(chip,(int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);

  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);
}

static void exec_lsr_a(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sr = SET_CARRY_FLAG(chip->sr, chip->a & 1);
  chip->a >>= 1;

  set_negative_flag(chip,(int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_nop(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  // Nothing.
}

static void exec_ora(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->a |= oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);

  set_negative_flag(chip,(int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_pha(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_push_stack(chip, chip->a, mem_size, mem, status);
}

static void exec_php(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_push_stack(chip, chip->sr, mem_size, mem, status);
}

static void exec_pla(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_read_stack(chip, mem_size, mem, status);
  chip->a = oku_6502_pop_stack(chip, mem_size, mem, status);

  set_negative_flag(chip,(int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_plp(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_read_stack(chip, mem_size, mem, status);
  chip->sr = oku_6502_pop_stack(chip, mem_size, mem, status);
}

static void exec_rol(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t tmp = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);
  int8_t would_carry = tmp < 0 ? 1 : 0;

  tmp = ((tmp & 0xFF) << 1) | CARRY_FLAG(chip->sr);
  chip->sr = SET_CARRY_FLAG(chip->sr, would_carry);

  set_negative_flag(chip,(int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);
  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);
}

static void exec_rol_a(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t tmp = ((int16_t)chip->a << 1) | (CARRY_FLAG(chip->sr));

  chip->a = tmp & 0xFF;

  set_carry_flag(chip, tmp);
  set_negative_flag(chip, (int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_ror(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int8_t tmp = oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);
  int8_t would_carry = tmp & 1;

  tmp = ((tmp & 0xFF) >> 1) | (CARRY_FLAG(chip->sr) << 7);
  chip->sr = SET_CARRY_FLAG(chip->sr, would_carry);

  set_negative_flag(chip,(int32_t)tmp);
  set_zero_flag(chip, (int32_t)tmp);
  oku_6502_chip_write_mem_i8(chip, chip->operand, tmp, mem_size, mem, status);
}

static void exec_ror_a(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t tmp = (int16_t)chip->a | (CARRY_FLAG(chip->sr) == 0 ? 0 : 0x100);
  chip->sr = SET_CARRY_FLAG(chip->sr, chip->a & 1);

  chip->a = tmp >> 1;

  set_negative_flag(chip, (int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_rti(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_read_stack(chip, mem_size, mem, status);
  exec_plp(chip, mem_size, mem, status);
  oku_6502_pop_pc(chip, mem_size, mem, status);
}

static void exec_rts(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_read_stack(chip, mem_size, mem, status);
  oku_6502_pop_pc(chip, mem_size, mem, status);
  oku_6502_read_pc_mem_i8(chip, mem_size, mem, status);
}

static void exec_sbc(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  int16_t op1 = (int16_t)chip->a;
  int16_t op2 = (int16_t)oku_6502_chip_read_mem_i8(chip, chip->operand, mem_size, mem, status);
  int16_t value = op1 - op2 - ((CARRY_FLAG(chip->sr) ^ 1) & 0x1);

  if (DECIMAL_MODE_FLAG(chip->sr) == 0)
  {
    chip->a = value & 0xFF;
    chip->sr = SET_OVERFLOW_FLAG(chip->sr, (((op1 ^ op2) & (op1 ^ chip->a) & 0x80) >> 7));

    set_borrow_flag(chip, value);
    set_negative_flag(chip, (int32_t)value);
    set_zero_flag(chip, (int32_t)value);
  }
  else
  {
    // decimal mode behavior following Marko Makela's explanations
    // Stolen from a java based 6502 interpreter
    // I'll be honest, I have no idea how this works.
    int16_t tmp;
    tmp = (op1 & 0x0F) - (op2 & 0x0F) - (CARRY_FLAG(chip->sr) ^ 1);

    chip->a = (tmp & 0x10) == 0 ? tmp : tmp - 6;

    tmp = (op1 & 0xF0) - (op2 & 0xF0) - (chip->a & 0x10);

    chip->a = (chip->a & 0x0F) | ((tmp & 0x100) == 0 ? tmp : tmp - 0x60);

    tmp = op1 - op2 - (CARRY_FLAG(chip->sr) ^ 1);

    set_borrow_flag(chip, tmp);
    set_negative_flag(chip, (int32_t)tmp);
    set_zero_flag(chip, (int32_t)tmp);
  }
}

static void exec_sec(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sr = SET_CARRY_FLAG(chip->sr, 1);
}

static void exec_sed(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sr = SET_DECIMAL_MODE_FLAG(chip->sr, 1);
}

static void exec_sei(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sr = SET_IRQ_DISABLE_FLAG(chip->sr, 1);
}

static void exec_sta(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_chip_write_mem_i8(chip, chip->operand, chip->a, mem_size, mem, status);
}

static void exec_stx(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_chip_write_mem_i8(chip, chip->operand, chip->x, mem_size, mem, status);
}

static void exec_sty(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  oku_6502_chip_write_mem_i8(chip, chip->operand, chip->y, mem_size, mem, status);
}

static void exec_tax(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->x = chip->a;

  set_negative_flag(chip, (int32_t)chip->x);
  set_zero_flag(chip, (int32_t)chip->x);
}

static void exec_tay(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->x = chip->a;

  set_negative_flag(chip, (int32_t)chip->x);
  set_zero_flag(chip, (int32_t)chip->x);
}

static void exec_tsx(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->x = chip->sp;

  set_negative_flag(chip, (int32_t)chip->x);
  set_zero_flag(chip, (int32_t)chip->x);
}

static void exec_txa(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->a = chip->x;

  set_negative_flag(chip, (int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

static void exec_txs(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->sp = chip->x;
}

static void exec_tya(struct oku_6502_chip* chip, int32_t mem_size, char* mem, int* status)
{
  chip->a = chip->y;

  set_negative_flag(chip, (int32_t)chip->a);
  set_zero_flag(chip, (int32_t)chip->a);
}

// Yes, this extension does not provide allocation of the chip or memory
// It only says what size the pointer needs to be in case you want to throw a
// block of memory at it.
extern int oku_6502_chip_size()
{
  return sizeof(struct oku_6502_chip);
}

//
// Initializer, pass a chip pointer and this will initialize it
//
extern void oku_6502_chip_init(struct oku_6502_chip* chip)
{
  chip->pc = 0; // TODO: this shouldn't start in the zeropage from what I remember
  chip->sp = 0x1FF;
  chip->a = 0;
  chip->x = 0;
  chip->y = 0;
  chip->sr = 0;
  chip->state = CPU_STATE_RESET;
  chip->cycles = 0;
  chip->operand = 0;
}

//
// Execute
//
extern int oku_6502_chip_exec(struct oku_6502_chip* chip, int32_t mem_size, char* mem)
{
  int status = INVALID_CODE;

  switch (chip->ir)
  {
    case 0x00: // BRK impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_brk(chip, mem_size, mem, &status);
      break;

    case 0x01: // ORA X,ind
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_ora(chip, mem_size, mem, &status);
      break;

    case 0x02:
    case 0x03:
    case 0x04:
      return HANG_CODE;

    case 0x05: // ORA zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_ora(chip, mem_size, mem, &status);
      break;

    case 0x06: // ASL zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_asl(chip, mem_size, mem, &status);
      break;

    case 0x07:
      return HANG_CODE;

    case 0x08: // PHP impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_php(chip, mem_size, mem, &status);
      break;

    case 0x09: // ORA #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_ora(chip, mem_size, mem, &status);
      break;

    case 0x0A: // ASL A
      exec_asl_a(chip, mem_size, mem, &status);
      break;

    case 0x0B:
    case 0x0C:
      return HANG_CODE;

    case 0x0D: // ORA abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_ora(chip, mem_size, mem, &status);
      break;

    case 0x0E: // ASL abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_asl(chip, mem_size, mem, &status);
      break;

    case 0x0F:
      return HANG_CODE;

    case 0x10: // BPL rel
      opr_relative_i16(chip, mem_size, mem, &status);
      exec_bpl(chip, mem_size, mem, &status);
      break;

    case 0x11: // ORA ind,Y
      opr_indirect_i16y(chip, mem_size, mem, &status);
      exec_ora(chip, mem_size, mem, &status);
      break;

    case 0x12:
    case 0x13:
    case 0x14:
      return HANG_CODE;

    case 0x15: // ORA zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_ora(chip, mem_size, mem, &status);
      break;

    case 0x16: // ASL zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_asl(chip, mem_size, mem, &status);
      break;

    case 0x17:
      return HANG_CODE;

    case 0x18: // CLC impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_clc(chip, mem_size, mem, &status);
      break;

    case 0x19: // ORA abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_ora(chip, mem_size, mem, &status);
      break;

    case 0x1A:
    case 0x1B:
    case 0x1C:
      return HANG_CODE;

    case 0x1D: // ORA abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_ora(chip, mem_size, mem, &status);
      break;

    case 0x1E: // ASL abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_asl(chip, mem_size, mem, &status);
      break;

    case 0x1F:
      return HANG_CODE;

    case 0x20: // JSR abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_jsr(chip, mem_size, mem, &status);
      break;

    case 0x21: // AND X,ind
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_and(chip, mem_size, mem, &status);
      break;

    case 0x22:
    case 0x23:
      return HANG_CODE;

    case 0x24: // BIT zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_bit(chip, mem_size, mem, &status);
      break;

    case 0x25: // AND zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_and(chip, mem_size, mem, &status);
      break;

    case 0x26: // ROL zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_rol(chip, mem_size, mem, &status);
      break;

    case 0x27:
      return HANG_CODE;

    case 0x28: // PLP impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_plp(chip, mem_size, mem, &status);
      break;

    case 0x29: // AND #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_and(chip, mem_size, mem, &status);
      break;

    case 0x2A: // ROL A
      exec_rol_a(chip, mem_size, mem, &status);
      break;

    case 0x2B:
      return HANG_CODE;

    case 0x2C: // BIT abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_bit(chip, mem_size, mem, &status);
      break;

    case 0x2D: // AND abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_and(chip, mem_size, mem, &status);
      break;

    case 0x2E: // ROL abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_rol(chip, mem_size, mem, &status);
      break;

    case 0x2F:
      return HANG_CODE;

    case 0x30: // BMI rel
      opr_relative_i16(chip, mem_size, mem, &status);
      exec_bmi(chip, mem_size, mem, &status);
      break;

    case 0x31: // AND ind,Y
      opr_indirect_i16y(chip, mem_size, mem, &status);
      exec_and(chip, mem_size, mem, &status);
      break;

    case 0x32:
    case 0x33:
    case 0x34:
      return HANG_CODE;

    case 0x35: // AND zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_and(chip, mem_size, mem, &status);
      break;

    case 0x36: // ROL zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_rol(chip, mem_size, mem, &status);
      break;

    case 0x37:
      return HANG_CODE;

    case 0x38: // SEC impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_sec(chip, mem_size, mem, &status);
      break;

    case 0x39: // AND abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_and(chip, mem_size, mem, &status);
      break;

    case 0x3A:
    case 0x3B:
    case 0x3C:
      return HANG_CODE;

    case 0x3D: // AND abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_and(chip, mem_size, mem, &status);
      break;

    case 0x3E: // ROL abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_rol(chip, mem_size, mem, &status);
      break;

    case 0x3F:
      return HANG_CODE;

    case 0x40: // RTI impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_rti(chip, mem_size, mem, &status);
      break;

    case 0x41: // EOR X,ind
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_eor(chip, mem_size, mem, &status);
      break;

    case 0x42:
    case 0x43:
    case 0x44:
      return HANG_CODE;

    case 0x45: // EOR zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_eor(chip, mem_size, mem, &status);
      break;

    case 0x46: // LSR zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_lsr(chip, mem_size, mem, &status);
      break;

    case 0x47:
      return HANG_CODE;

    case 0x48: // PHA impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_pha(chip, mem_size, mem, &status);
      break;

    case 0x49: // EOR #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_eor(chip, mem_size, mem, &status);
      break;

    case 0x4A: // LSR A
      exec_lsr_a(chip, mem_size, mem, &status);
      break;

    case 0x4B:
      return HANG_CODE;

    case 0x4C: // JMP abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_jmp(chip, mem_size, mem, &status);
      break;

    case 0x4D: // EOR abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_eor(chip, mem_size, mem, &status);
      break;

    case 0x4E: // LSR abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_lsr(chip, mem_size, mem, &status);
      break;

    case 0x4F:
      return HANG_CODE;

    case 0x50: // BVC rel
      opr_relative_i16(chip, mem_size, mem, &status);
      exec_bvc(chip, mem_size, mem, &status);
      break;

    case 0x51: // EOR ind,Y
      opr_indirect_i16y(chip, mem_size, mem, &status);
      exec_eor(chip, mem_size, mem, &status);
      break;

    case 0x52:
    case 0x53:
    case 0x54:
      return HANG_CODE;

    case 0x55: // EOR zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_eor(chip, mem_size, mem, &status);
      break;

    case 0x56: // LSR zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_lsr(chip, mem_size, mem, &status);
      break;

    case 0x57:
      return HANG_CODE;

    case 0x58: // CLI impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_cli(chip, mem_size, mem, &status);
      break;

    case 0x59: // EOR abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_eor(chip, mem_size, mem, &status);
      break;

    case 0x5A:
    case 0x5B:
    case 0x5C:
      return HANG_CODE;

    case 0x5D: // EOR abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_eor(chip, mem_size, mem, &status);
      break;

    case 0x5E: // LSR abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_lsr(chip, mem_size, mem, &status);
      break;

    case 0x5F:
      return HANG_CODE;

    case 0x60: // RTS impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_rts(chip, mem_size, mem, &status);
      break;

    case 0x61: // ADC X,ind
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_adc(chip, mem_size, mem, &status);
      break;

    case 0x62:
    case 0x63:
    case 0x64:
      return HANG_CODE;

    case 0x65: // ADC zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_adc(chip, mem_size, mem, &status);
      break;

    case 0x66: // ROR zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_ror(chip, mem_size, mem, &status);
      break;

    case 0x67:
      return HANG_CODE;

    case 0x68: // PLA impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_pla(chip, mem_size, mem, &status);
      break;

    case 0x69: // ADC #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_adc(chip, mem_size, mem, &status);
      break;

    case 0x6A: // ROR A
      exec_ror_a(chip, mem_size, mem, &status);
      break;

    case 0x6B:
      return HANG_CODE;

    case 0x6C: // JMP ind
      opr_indirect_i16(chip, mem_size, mem, &status);
      exec_jmp(chip, mem_size, mem, &status);
      break;

    case 0x6D: // ADC abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_adc(chip, mem_size, mem, &status);
      break;

    case 0x6E: // ROR abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_ror(chip, mem_size, mem, &status);
      break;

    case 0x6F:
      return HANG_CODE;

    case 0x70: // BVS rel
      opr_relative_i16(chip, mem_size, mem, &status);
      exec_bvs(chip, mem_size, mem, &status);
      break;

    case 0x71: // ADC ind,Y
      opr_indirect_i16y(chip, mem_size, mem, &status);
      exec_adc(chip, mem_size, mem, &status);
      break;

    case 0x72:
    case 0x73:
    case 0x74:
      return HANG_CODE;

    case 0x75: // ADC zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_adc(chip, mem_size, mem, &status);
      break;

    case 0x76: // ROR zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_ror(chip, mem_size, mem, &status);
      break;

    case 0x77:
      return HANG_CODE;

    case 0x78: // SEI impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_sei(chip, mem_size, mem, &status);
      break;

    case 0x79: // ADC abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_adc(chip, mem_size, mem, &status);
      break;

    case 0x7A:
    case 0x7B:
    case 0x7C:
      return HANG_CODE;

    case 0x7D: // ADC abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_adc(chip, mem_size, mem, &status);
      break;

    case 0x7E: // ROR abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_ror(chip, mem_size, mem, &status);
      break;

    case 0x7F:
      return HANG_CODE;

    case 0x80:
      return HANG_CODE;

    case 0x81: // STA X,ind
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_sta(chip, mem_size, mem, &status);
      break;

    case 0x82:
    case 0x83:
      return HANG_CODE;

    case 0x84: // STY zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_sty(chip, mem_size, mem, &status);
      break;

    case 0x85: // STA zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_sta(chip, mem_size, mem, &status);
      break;

    case 0x86: // STX zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_stx(chip, mem_size, mem, &status);
      break;

    case 0x87:
      return HANG_CODE;

    case 0x88: // DEY impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_dey(chip, mem_size, mem, &status);
      break;

    case 0x89:
      return HANG_CODE;

    case 0x8A: // TXA impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_txa(chip, mem_size, mem, &status);
      break;

    case 0x8B:
      return HANG_CODE;

    case 0x8C: // STY abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_sty(chip, mem_size, mem, &status);
      break;

    case 0x8D: // STA abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_sta(chip, mem_size, mem, &status);
      break;

    case 0x8E: // STX abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_stx(chip, mem_size, mem, &status);
      break;

    case 0x8F:
      return HANG_CODE;

    case 0x90: // BCC rel
      opr_relative_i16(chip, mem_size, mem, &status);
      exec_bcc(chip, mem_size, mem, &status);
      break;

    case 0x91: // STA ind,Y
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_sta(chip, mem_size, mem, &status);
      break;

    case 0x92:
    case 0x93:
      return HANG_CODE;

    case 0x94: // STY zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_sty(chip, mem_size, mem, &status);
      break;

    case 0x95: // STA zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_sta(chip, mem_size, mem, &status);
      break;

    case 0x96: // STX zpg,Y
      opr_zeropage_i16y(chip, mem_size, mem, &status);
      exec_stx(chip, mem_size, mem, &status);
      break;

    case 0x97:
      return HANG_CODE;

    case 0x98: // TYA impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_tya(chip, mem_size, mem, &status);
      break;

    case 0x99: // STA abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_sta(chip, mem_size, mem, &status);
      break;

    case 0x9A: // TXS impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_txs(chip, mem_size, mem, &status);
      break;

    case 0x9B:
    case 0x9C:
      return HANG_CODE;

    case 0x9D: // STA abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_sta(chip, mem_size, mem, &status);
      break;

    case 0x9E:
    case 0x9F:
      return HANG_CODE;

    case 0xA0: // LDY #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_ldy(chip, mem_size, mem, &status);
      break;

    case 0xA1: // LDA X,ind
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_lda(chip, mem_size, mem, &status);
      break;

    case 0xA2: // LDX #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_ldx(chip, mem_size, mem, &status);
      break;

    case 0xA3:
      return HANG_CODE;

    case 0xA4: // LDY zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_ldy(chip, mem_size, mem, &status);
      break;

    case 0xA5: // LDA zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_lda(chip, mem_size, mem, &status);
      break;

    case 0xA6: // LDX zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_ldx(chip, mem_size, mem, &status);
      break;

    case 0xA7:
      return HANG_CODE;

    case 0xA8: // TAY impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_tay(chip, mem_size, mem, &status);
      break;

    case 0xA9: // LDA #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_lda(chip, mem_size, mem, &status);
      break;

    case 0xAA: // TAX impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_tax(chip, mem_size, mem, &status);
      break;

    case 0xAB:
      return HANG_CODE;

    case 0xAC: // LDY abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_ldy(chip, mem_size, mem, &status);
      break;

    case 0xAD: // LDA abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_lda(chip, mem_size, mem, &status);
      break;

    case 0xAE: // LDX abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_ldx(chip, mem_size, mem, &status);
      break;

    case 0xAF:
      return HANG_CODE;

    case 0xB0: // BCS rel
      opr_relative_i16(chip, mem_size, mem, &status);
      exec_bcs(chip, mem_size, mem, &status);
      break;

    case 0xB1: // LDA ind,Y
      opr_indirect_i16y(chip, mem_size, mem, &status);
      exec_lda(chip, mem_size, mem, &status);
      break;

    case 0xB2:
    case 0xB3:
      return HANG_CODE;

    case 0xB4: // LDY zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_ldy(chip, mem_size, mem, &status);
      break;

    case 0xB5: // LDA zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_lda(chip, mem_size, mem, &status);
      break;

    case 0xB6: // LDX zpg,Y
      opr_zeropage_i16y(chip, mem_size, mem, &status);
      exec_ldx(chip, mem_size, mem, &status);
      break;

    case 0xB7:
      return HANG_CODE;

    case 0xB8: // CLV impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_clv(chip, mem_size, mem, &status);
      break;

    case 0xB9: // LDA abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_lda(chip, mem_size, mem, &status);
      break;

    case 0xBA: // TSX impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_tsx(chip, mem_size, mem, &status);
      break;

    case 0xBB:
      return HANG_CODE;

    case 0xBC: // LDY abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_ldy(chip, mem_size, mem, &status);
      break;

    case 0xBD: // LDA abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_lda(chip, mem_size, mem, &status);
      break;

    case 0xBE: // LDX abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_ldx(chip, mem_size, mem, &status);
      break;

    case 0xBF:
      return HANG_CODE;

    case 0xC0: // CPY #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_cpy(chip, mem_size, mem, &status);
      break;

    case 0xC1: // CMP X,ind
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_cmp(chip, mem_size, mem, &status);
      break;

    case 0xC2:
    case 0xC3:
      return HANG_CODE;

    case 0xC4: // CPY zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_cpy(chip, mem_size, mem, &status);
      break;

    case 0xC5: // CMP zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_cmp(chip, mem_size, mem, &status);
      break;

    case 0xC6: // DEC zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_dec(chip, mem_size, mem, &status);
      break;

    case 0xC7:
      return HANG_CODE;

    case 0xC8: // INY impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_iny(chip, mem_size, mem, &status);
      break;

    case 0xC9: // CMP #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_cmp(chip, mem_size, mem, &status);
      break;

    case 0xCA: // DEX impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_dex(chip, mem_size, mem, &status);
      break;

    case 0xCB:
      return HANG_CODE;

    case 0xCC: // CPY abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_cpy(chip, mem_size, mem, &status);
      break;

    case 0xCD: // CMP abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_cmp(chip, mem_size, mem, &status);
      break;

    case 0xCE: // DEC abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_dec(chip, mem_size, mem, &status);
      break;

    case 0xCF:
      return HANG_CODE;

    case 0xD0: // BNE rel
      opr_relative_i16(chip, mem_size, mem, &status);
      exec_bne(chip, mem_size, mem, &status);
      break;

    case 0xD1: // CMP ind,Y
      opr_indirect_i16y(chip, mem_size, mem, &status);
      exec_cmp(chip, mem_size, mem, &status);
      break;

    case 0xD2:
    case 0xD3:
    case 0xD4:
      return HANG_CODE;

    case 0xD5: // CMP zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_cmp(chip, mem_size, mem, &status);
      break;

    case 0xD6: // DEC zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_dec(chip, mem_size, mem, &status);
      break;

    case 0xD7:
      return HANG_CODE;

    case 0xD8: // CLD impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_cld(chip, mem_size, mem, &status);
      break;

    case 0xD9: // CMP abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_cmp(chip, mem_size, mem, &status);
      break;

    case 0xDA:
    case 0xDB:
    case 0xDC:
      return HANG_CODE;

    case 0xDD: // CMP abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_cmp(chip, mem_size, mem, &status);
      break;

    case 0xDE: // DEC abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_dec(chip, mem_size, mem, &status);
      break;

    case 0xDF:
      return HANG_CODE;

    case 0xE0: // CPX #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_cpx(chip, mem_size, mem, &status);
      break;

    case 0xE1: // SBC X,ind
      opr_indirect_i16x(chip, mem_size, mem, &status);
      exec_sbc(chip, mem_size, mem, &status);
      break;

    case 0xE2:
    case 0xE3:
      return HANG_CODE;

    case 0xE4: // CPX zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_cpx(chip, mem_size, mem, &status);
      break;

    case 0xE5: // SBC zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_sbc(chip, mem_size, mem, &status);
      break;

    case 0xE6: // INC zpg
      opr_zeropage_i16(chip, mem_size, mem, &status);
      exec_inc(chip, mem_size, mem, &status);
      break;

    case 0xE7:
      return HANG_CODE;

    case 0xE8: // INX impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_inx(chip, mem_size, mem, &status);
      break;

    case 0xE9: // SBC #
      opr_immediate_i8(chip, mem_size, mem, &status);
      exec_sbc(chip, mem_size, mem, &status);
      break;

    case 0xEA: // NOP impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_nop(chip, mem_size, mem, &status);
      break;

    case 0xEB:
      return HANG_CODE;

    case 0xEC: // CPX abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_cpx(chip, mem_size, mem, &status);
      break;

    case 0xED: // SBC abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_sbc(chip, mem_size, mem, &status);
      break;

    case 0xEE: // INC abs
      opr_absolute_i16(chip, mem_size, mem, &status);
      exec_inc(chip, mem_size, mem, &status);
      break;

    case 0xEF:
      return HANG_CODE;

    case 0xF0: // BEQ rel
      opr_relative_i16(chip, mem_size, mem, &status);
      exec_beq(chip, mem_size, mem, &status);
      break;

    case 0xF1: // SBC ind,Y
      opr_indirect_i16y(chip, mem_size, mem, &status);
      exec_sbc(chip, mem_size, mem, &status);
      break;

    case 0xF2:
    case 0xF3:
    case 0xF4:
      return HANG_CODE;

    case 0xF5: // SBC zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_sbc(chip, mem_size, mem, &status);
      break;

    case 0xF6: // INC zpg,X
      opr_zeropage_i16x(chip, mem_size, mem, &status);
      exec_inc(chip, mem_size, mem, &status);
      break;

    case 0xF7:
      return HANG_CODE;

    case 0xF8: // SED impl
      opr_implied_i8(chip, mem_size, mem, &status);
      exec_sed(chip, mem_size, mem, &status);
      break;

    case 0xF9: // SBC abs,Y
      opr_absolute_i16y(chip, mem_size, mem, &status);
      exec_sbc(chip, mem_size, mem, &status);
      break;

    case 0xFA:
    case 0xFB:
    case 0xFC:
      return HANG_CODE;

    case 0xFD: // SBC abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_sbc(chip, mem_size, mem, &status);
      break;

    case 0xFE: // INC abs,X
      opr_absolute_i16x(chip, mem_size, mem, &status);
      exec_inc(chip, mem_size, mem, &status);
      break;

    case 0xFF:
      return HANG_CODE;
  }
  return status;
}

extern int oku_6502_chip_fetch(struct oku_6502_chip* chip, int32_t mem_size, char* mem)
{
  int status = INVALID_CODE;

  uint8_t opcode = (uint8_t)oku_6502_read_pc_mem_i8(chip, mem_size, mem, &status);
  if (status != OK_CODE)
  {
    return status;
  }

  chip->ir = opcode;
  return oku_6502_chip_exec(chip, mem_size, mem);
}

extern int oku_6502_chip_fex(struct oku_6502_chip* chip, int32_t mem_size, char* mem)
{
  int status;
  status = oku_6502_chip_fetch(chip, mem_size, mem);
  if (status != OK_CODE)
  {
    return status;
  }

  status = oku_6502_chip_exec(chip, mem_size, mem);
  return status;
}

//
// Startup stepping logic
//
#define NEXT_STAGE(value) (((((value) >> 4) & 0xF) + 1) << 4) | ((value) & 0xF);

extern int oku_6502_chip_startup(struct oku_6502_chip* chip, int32_t mem_size, char* mem)
{
  int status = 0;
  int8_t startup_stage = (chip->state >> 4) & 0xF;

  // NMI_VECTOR_PTR
  // RESET_VECTOR_PTR
  // IRQ_VECTOR_PTR
  // BREAK_VECTOR_PTR

  switch (startup_stage)
  {
    // Reset Sequence
    // References: https://www.youtube.com/watch?v=LnzuMJLZRdU
    //             https://www.youtube.com/watch?v=yl8vPW5hydQ
    // Not totally sure what's happening inside the chip though, page tables sorta knows.
    case 0:
      chip->ab = chip->pc;
      oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status);
      chip->a = 0xAA;
      chip->ir = 0x00;
      chip->sr = 0x02;
      chip->state = NEXT_STAGE(chip->state);
      return STARTUP_CODE;

    case 1:
      chip->ab = chip->pc;
      oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status);
      chip->a = 0xAA;
      chip->ir = 0x00;
      chip->sr = 0x02;
      chip->state = NEXT_STAGE(chip->state);
      return STARTUP_CODE;

    case 2:
      chip->ab = chip->pc;
      oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status);
      chip->pc = 0x00FF;
      chip->a = 0xAA;
      chip->ir = 0x00;
      chip->sr = 0x02;
      chip->state = NEXT_STAGE(chip->state);
      return STARTUP_CODE;

    case 3:
      chip->ab = 0xFFFF;
      oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status);
      chip->a = 0xAA;
      chip->ir = 0x00;
      chip->sr = 0x02;
      chip->state = NEXT_STAGE(chip->state);
      return STARTUP_CODE;

    case 4:
      chip->ab = 0x01F7;
      oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status);
      chip->pc = 0x00FF;
      chip->a = 0xAA;
      chip->ir = 0x00;
      chip->sr = 0x02;
      chip->state = NEXT_STAGE(chip->state);
      return STARTUP_CODE;

    case 5:
      chip->ab = 0x01F6;
      oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status);
      chip->pc = 0x00FF;
      chip->a = 0xAA;
      chip->ir = 0x00;
      chip->sr = 0x02;
      chip->state = NEXT_STAGE(chip->state);
      return STARTUP_CODE;

    case 6:
      chip->ab = 0x01F5;
      oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status);
      chip->pc = 0x00FF;
      chip->a = 0xAA;
      chip->ir = 0x00;
      chip->sr = 0x02;
      chip->state = NEXT_STAGE(chip->state);
      return STARTUP_CODE;

    // PC initialize
    case 7:
      chip->ab = RESET_VECTOR_PTR;
      chip->pc = (uint16_t)oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status);
      chip->state = NEXT_STAGE(chip->state);
      return STARTUP_CODE;

    case 8:
      chip->ab = RESET_VECTOR_PTR + 1;
      chip->pc |= ((uint16_t)oku_6502_chip_read_mem_i8(chip, chip->ab, mem_size, mem, &status)) << 8;
      chip->state = CPU_STATE_RUN;
      return OK_CODE;

    default:
      chip->state = CPU_STATE_HANG;
      return HANG_CODE;
  }
}

//
// Step
//
extern int oku_6502_chip_step(struct oku_6502_chip* chip, int32_t mem_size, char* mem)
{
  switch (chip->state & 0xF)
  {
    case CPU_STATE_RESET:
      return oku_6502_chip_startup(chip, mem_size, mem);

    case CPU_STATE_RUN:
      return oku_6502_chip_fex(chip, mem_size, mem);

    case CPU_STATE_HANG:
      return HANG_CODE;

    default:
      return INVALID_CODE;
  }
}
