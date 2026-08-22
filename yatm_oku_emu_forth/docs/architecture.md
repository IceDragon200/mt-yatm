# OKU Forth architecture

## Machine model

OKU Forth is a high-level token-threaded stack machine. It is designed to be a
small programmable architecture for OKU rather than a binary-compatible model
of historical Forth hardware.

Three architectures share the same implementation:

| Architecture | Cell width | Default RAM | Dictionary budget |
| --- | ---: | ---: | ---: |
| `oku_forth8` | 8 bits | 256 bytes | 4 KiB |
| `oku_forth16` | 16 bits | 64 KiB | 8 KiB |
| `oku_forth32` | 32 bits | 64 KiB | 16 KiB |

Cell width controls signed arithmetic results, Boolean values, shifts, data
stack cells, and `@`/`!` accesses. Addresses remain byte addresses. `CELLS`
converts a cell count to bytes.

The data stack grows downward through guest RAM. All complete cells are
available to it. Programs may use the rest of RAM directly, but are responsible
for not overwriting their active data stack.

The return stack, execution stack, dictionary, and compiler state are managed
by the VM and do not consume guest RAM.

## Execution and definitions

Input is split on ordinary whitespace. Parenthesized comments and backslash to
end-of-line comments are ignored. Names are case-insensitive.

Numbers are pushed onto the data stack. Names resolve first against the user
dictionary and then against built-ins. Colon definitions are compiled into
serializable token arrays:

```forth
: SQUARE DUP * ;
: ABS2 DUP 0< IF -1 * THEN ;
5 SQUARE
```

User-word calls are deliberately late-bound by name. Redefining a word also
changes existing definitions which call that name. This differs from
traditional Forth systems that capture an execution token at compilation time,
but supports live replacement and keeps the serialized representation simple.

Control structures compile to private structured tokens rather than guest
addresses. Programs cannot manufacture these tokens through ordinary input.
Supported structures are:

- `IF ... THEN`
- `IF ... ELSE ... THEN`
- `BEGIN ... UNTIL`
- `BEGIN ... AGAIN`
- `BEGIN ... WHILE ... REPEAT`

The host controls how many VM steps are executed, so an intentional `AGAIN`
loop cannot monopolize a server in one `step` call.

## Resource limits

Host-managed state still behaves as a finite machine resource:

- Dictionary budget: configurable through `dictionary_size`.
- User words: at most 256.
- Word names: at most 64 bytes.
- Definition bodies: at most 1,024 top-level tokens.
- Execution stack: at most 4,096 tokens.
- Return stack: at most 256 cells.

Dictionary accounting uses deterministic virtual byte costs, not Lua's
implementation-dependent table sizes. Built-ins do not consume the budget.
Redefinition atomically replaces the previous word's charge. Bindump loading
restores and validates dictionary accounting.

## Vocabulary

Arithmetic:

```text
+ - * / MOD ABS
```

Comparison and Boolean operations use `0` for false and an all-bits-set cell
(`-1` when read as signed) for true:

```text
= <> < > 0= 0<
```

Bitwise operations:

```text
AND OR XOR INVERT LSHIFT RSHIFT
```

Data-stack operations:

```text
DUP DROP SWAP NIP OVER TUCK ROT
```

Return-stack operations:

```text
>R R> 2>R 2R>
```

Memory and cell operations:

```text
@ ! MOVE CELLS WORD_SIZE
```

Output and constants:

```text
. emit BL
```

## Persistence

Bindumps include guest memory, output, user definitions, pending execution,
the return stack, and data-stack position. Compiled definitions contain only
plain serializable values; Lua functions are supplied again by the architecture
when a machine is loaded.
