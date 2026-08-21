# ACTU8

Pronounced "Actuate", is a small instruction set and machine architecture provided by OKU out of the box.

## Machine

ACTU8's encoding SHALL BE little-endian.

ACTU8's structure:

```zig
struct {
  a: u8,
  pc: u16,
  sp: u8,
  flags: packed struct {
    zero: bool,
    borrow: bool,
    carry: bool,
    interrupt: bool,
    halt: bool,
    fault: bool,
    _padding: u2,
  },
  fc: u8
}
```

Machine execution is considered suspended if:
* `flags.halt` is set and may be unset externally, the machine will resume execution like normal.
* `flags.fault` is set and should be considered unrecoverable normally, externally modification of the machine's state may be required to recover, but a hard reset is recommended instead.

A machine can resume execution with its `interrupt` flag set externally, this notifies the machine that it has resumed execution from an interrupt.

The machine CAN clear its zero, borrow, carry or interrupt flags using its respective instructions.

## Fault Codes

* `0` - OK
* `1` - Stack Underflow
* `2` - Stack Overflow
* `3` - Unrecognized Instruction
* `4` - Access Violation (attempted to address something that was considered protected or unavailable, this applies to something that could have been addressed)
* `255` - Segfault (attempted to access a memory location that does not exist)

## Memory Layout

Given 2048 bytes:

* 0x000..0x4FF - Program / .text
* 0x500..0x5FF - IO Page
* 0x600..0x6FF - RAM
* 0x700..0x7FF - Stack

The system requires a minimum of 1024 bytes to function, where the .text will flex.

The IO Page may be monitored by external peripherals and can act upon it changing even during machine execution, it's layout and structure depends on what the user requires, the only limitation is it is fixed to 256 bytes of addressable memory.

## Stack

`sp` shall be initialized to its maximum possible value (255), representing the very end of addressable memory.

Before the stack is manipulated, the machine SHALL check whether or not an operation would exceed its unsigned limits: that is 0..255, any attempt to overflow OR underflow the `sp` register SHALL set `flags.fault` and a corresponding fault code `fc` and abort execution before any changes are made.

Subsequent resumes SHALL abort immediately, the machine MUST be reset to recover or externally modified.

## Addressing

* `addr8` SHALL be a unsigned 8-bit integer
* `addr16` SHALL be a unsigned 16-bit integer

Instructions that use `addr16` for its addressing are normally working only on the `Program` pages, while it is possible to execute from the RAM page, it is discouraged.

Instructions that use `addr8` are context dependent and are offsets within their respective pages.

For example: ADD, SUB, etc... operate on RAM, while IN and OUT operate on the IO page.

## Instructions

* [ADD](#add)
* [AND](#and)
* [CALL](#call)
* [CLB](#clb)
* [CLC](#clc)
* [CLI](#cli)
* [CLZ](#clz)
* [CMP](#cmp)
* [HALT](#halt)
* [IN](#in)
* [JB](#jb)
* [JC](#jc)
* [JI](#ji)
* [JMP](#jmp)
* [JNB](#jnb)
* [JNC](#jnc)
* [JNI](#jni)
* [JNZ](#jnz)
* [JZ](#jz)
* [LDA](#lda)
* [LDI](#ldi)
* [NOP](#nop)
* [OR](#or)
* [OUT](#out)
* [POP](#pop)
* [PUSH](#push)
* [RET](#ret)
* [STA](#sta)
* [SUB](#sub)
* [XOR](#xor)

| Opcode | Name          | Operand |
| ------ | ----          | ---     |
| 0x00   | [NOP](#nop)   |         |
| 0x01   | [HALT](#halt) |         |
| 0x10   | [LDI](#ldi)   | imm:u8  |
| 0x11   | [LDA](#lda)   | addr8   |
| 0x12   | [STA](#sta)   | addr8   |
| 0x13   | [PUSH](#push) |         |
| 0x14   | [POP](#pop)   |         |
| 0x20   | [ADD](#add)   | addr8   |
| 0x21   | [SUB](#sub)   | addr8   |
| 0x22   | [CMP](#cmp)   | addr8   |
| 0x30   | [AND](#and)   | addr8   |
| 0x31   | [OR](#or)     | addr8   |
| 0x32   | [XOR](#xor)   | addr8   |
| 0x40   | [CLZ](#clz)   |         |
| 0x41   | [CLC](#clc)   |         |
| 0x42   | [CLB](#clb)   |         |
| 0x43   | [CLI](#cli)   |         |
| 0x50   | [JMP](#jmp)   | addr16  |
| 0x51   | [CALL](#call) | addr16  |
| 0x52   | [RET](#ret)   |         |
| 0x60   | [JZ](#jz)     | addr16  |
| 0x61   | [JNZ](#jnz)   | addr16  |
| 0x62   | [JC](#jc)     | addr16  |
| 0x63   | [JNC](#jnc)   | addr16  |
| 0x64   | [JB](#jb)     | addr16  |
| 0x65   | [JNB](#jnb)   | addr16  |
| 0x66   | [JI](#ji)     | addr16  |
| 0x67   | [JNI](#jni)   | addr16  |
| 0x70   | [IN](#in)     | addr8   |
| 0x71   | [OUT](#out)   | addr8   |

### ADD

`ADD <addr8>`

Adds RAM address value at `addr8` to register `a`.

See also:
* [SUB](#sub)

Flag Conditions:
* `borrow` `false`
* `carry` `(a + ram[addr8]) > 255`
* `zero` `((a + ram[addr8]) % 256) == 0`

### AND

`AND <addr8>`

Performs a binary AND with register `a` and RAM addressed value at `addr8`.

See also:
* [OR](#or)
* [XOR](#xor)

Flag Conditions:
* `zero` `(a BAND ram[addr8]) == 0`

### CALL

`CALL <addr16>`

Pushes the next `pc` (the instruction after the CALL) to the stack in 2 values, its hi and lo and jumps to the specified address.

The process can be reversed with `RET`.

See also:
* [RET](#ret)

### CLB

`CLB`

Clears the borrow flag.

See also:
* [CLC](#clc)
* [CLI](#cli)
* [CLZ](#clz)

### CLC

`CLC`

Clears the carry flag.

See also:
* [CLB](#clb)
* [CLI](#cli)
* [CLZ](#clz)

### CLI

`CLI`

Clears the interrupt flag.

See also:
* [CLB](#clb)
* [CLC](#clc)
* [CLZ](#clz)

### CLZ

`CLZ`

Clears the zero flag.

See also:
* [CLB](#clb)
* [CLC](#clc)
* [CLI](#cli)

### CMP

`CMP <addr8>`

Compares register `a` with value from RAM address `addr8`, setting `borrow`, `carry` or `zero` based on the result, see the Flag conditions below for more information.

See also:
* [ADD](#add)
* [JB](#jb)
* [JC](#jc)
* [JZ](#jz)
* [JNB](#jnb)
* [JNC](#jnc)
* [JNZ](#jnz)
* [SUB](#sub)

Flag conditions:
* `borrow` `(a < ram[addr8])`
* `carry` `(a > ram[addr8])`
* `zero` `(a == ram[addr8])`

### HALT

`HALT`

Sets `flags.halt` and advances `pc`.

The machine will not resume execution immediately until `flags.halt` is cleared.

### IN

`IN <addr8>`

Read a byte from `addr8` IO address into `a`.

`addr8` may be any `u8` address matching the IO Page.

See also:
* [OUT](#out)

Flag Conditions:
* `zero` `(a = IO[addr8]) == 0`

### JB

`JB <addr16>`

Jumps to the specified program address if `flags.borrow` is set.

See also:
* [JC](#jc)
* [JI](#ji)
* [JMP](#jmp)
* [JNB](#jnb)
* [JNC](#jnc)
* [JNI](#jni)
* [JNZ](#jnz)
* [JZ](#jz)

### JC

`JC <addr16>`

Jumps to the specified program address if `flags.carry` is set.

See also:
* [JB](#jb)
* [JI](#ji)
* [JMP](#jmp)
* [JNB](#jnb)
* [JNC](#jnc)
* [JNI](#jni)
* [JNZ](#jnz)
* [JZ](#jz)

### JI

`JI <addr16>`

Jumps to the specified program address if `flags.interrupt` is set.

See also:
* [JB](#jb)
* [JC](#jc)
* [JMP](#jmp)
* [JNB](#jnb)
* [JNC](#jnc)
* [JNI](#jni)
* [JNZ](#jnz)
* [JZ](#jz)

### JMP

`JMP <addr16>`

Jumps to the specified program address.

See also:
* [JB](#jb)
* [JC](#jc)
* [JI](#ji)
* [JNB](#jnb)
* [JNC](#jnc)
* [JNI](#jni)
* [JNZ](#jnz)
* [JZ](#jz)

### JNB

`JNB <addr16>`

Jumps to the specified program address if `flags.borrow` is not set.

See also:
* [JB](#jb)
* [JC](#jc)
* [JI](#ji)
* [JMP](#jmp)
* [JNC](#jnc)
* [JNI](#jni)
* [JNZ](#jnz)
* [JZ](#jz)

### JNC

`JNC <addr16>`

Jumps to the specified program address if `flags.carry` is not set.

See also:
* [JB](#jb)
* [JC](#jc)
* [JI](#ji)
* [JMP](#jmp)
* [JNB](#jnb)
* [JNI](#jni)
* [JNZ](#jnz)
* [JZ](#jz)

### JNI

`JNI <addr16>`

Jumps to the specified program address if `flags.interrupt` is not set.

See also:
* [JB](#jb)
* [JC](#jc)
* [JI](#ji)
* [JMP](#jmp)
* [JNB](#jnb)
* [JNC](#jnc)
* [JNZ](#jnz)
* [JZ](#jz)

### JNZ

`JNZ <addr16>`

Jumps to the specified program address if `flags.zero` is not set.

See also:
* [JB](#jb)
* [JC](#jc)
* [JI](#ji)
* [JMP](#jmp)
* [JNB](#jnb)
* [JNI](#jni)
* [JNC](#jnc)
* [JZ](#jz)

### JZ

`JZ <addr16>`

Jumps to the specified program address if `flags.zero` is set.

See also:
* [JB](#jb)
* [JC](#jc)
* [JI](#ji)
* [JMP](#jmp)
* [JNB](#jnb)
* [JNC](#jnc)
* [JNI](#jni)
* [JNZ](#jnz)

### LDA

`LDA <addr8>`

Loads RAM address value at `addr8` into register `a`.

See also:
* [LDI](#ldi)

Flag Conditions:
* `zero` `(a = ram[addr8]) == 0`

### LDI

`LDI <imm:u8>`

Loads `imm` into register `a`.

Note. A negative integer can be provided the assembler will transform it into two's complement.

See also:
* [LDA](#lda)

* `zero` `(a = imm) == 0`

### NOP

`NOP`

No-operation, does... nothing, does however consume a cycle.

### OR

`OR <addr8>`

Performs a binary OR with register `a` and value at `addr8` in RAM.

See also:
* [AND](#and)
* [XOR](#xor)

Flag Conditions:
* `zero` `(a BOR ram[addr8]) == 0`

### OUT

`OUT <addr8>`

Write `a` to the IO address `addr8`.

`addr8` may be any `u8` address matching the IO Page.

Note, writing to an address may cause execution of the machine to yield control to the calling process (in more technical terms, OKU will abort stepping and return control to the rest of the system).

See also:
* [IN](#in)

### POP

`POP`

Takes byte from stack storing it in register `a` and incrementing the `sp` register, if the `sp` would exceed 255, the machine will set `flags.fault`.

See also:
* [PUSH](#push)

Flag Conditions:
* `zero` `(a = STACK[sp]) == 0`

### PUSH

`PUSH`

Decrements `sp`, pushes the value in register `a` to the stack at the address `sp`.

If `sp` would become less than 0, the machine will set `flags.fault`.

See also:
* [POP](#pop)

### RET

`RET`

Pops 2 values from stack, being the hi and lo values of the `pc` register respectively, execution resumes from the new `pc`.

This effectively completes the `CALL`.

See also:
* [CALL](#call)

### STA

`STA <addr8>`

Stores the value in register `a` in RAM address `addr8`.

See also:
* [LDA](#lda)

### SUB

`SUB <addr8>`

Subtracts value in RAM address `addr8` from register `a`.

See also:
* [ADD](#add)

Flag Conditions:
* `borrow` `(a - ram[addr8]) < 0`
* `carry` `false`
* `zero` `((a - ram[addr8]) % 256) == 0`

### XOR

`XOR <addr8>`

Performs a binary xor operation on register `a` with value from RAM address `addr8`.

See also:
* [AND](#and)
* [OR](#or)

Flag Conditions:
* `zero` `(a BXOR ram[addr8]) == 0`
