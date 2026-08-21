# MOS 6502 Conformance Progress

This is the working ledger for the conformance effort. The normative behavior
lives in [mos6502.md](mos6502.md); this file records implementation progress and
known gaps.

## Status

| Area | Specified | Mirrored tests | Lua | Native | Notes |
| --- | :---: | :---: | :---: | :---: | --- |
| Backend loading | yes | yes | pass | pass | Native requires this mod's insecure environment |
| Reset | yes | yes | pass | pass | Seven accesses, vector, `SP -= 3`, `I = 1` |
| Addressing modes | yes | yes | pass | pass | All `LDA`/`STA` modes plus `JMP` and relative regressions |
| Loads/stores/transfers | yes | yes | pass | pass | All official encodings; boundary `N`/`Z` vectors |
| Stack / JSR / RTS | yes | yes | pass | pass | Wrap, byte order, exact and nested returns |
| Flags / branches | yes | yes | pass | pass | All conditions both ways, page crossings, set/clear and NOP |
| Logic / compare / BIT | yes | partial | pass | pass | Semantics pinned; full logic/compare encoding matrix remains |
| Shift / rotate | yes | yes | pass | pass | All 20 official encodings, carry-in/out and flags |
| Binary ADC / SBC | yes | yes | pass | pass | All 262,144 input tuples per backend; all 16 encodings |
| Decimal ADC / SBC | yes | yes | pass | pass | Bruce Clark oracle; all inputs including invalid BCD |
| BRK / RTI | yes | yes | pass | pass | Exact frame, vector, `I`, and restoration |
| External IRQ / NMI | partial | blocked | n/a | n/a | External interface not yet designed |
| Functional binary | yes | opt-in | pass | pass | Klaus completes at `$3469`; 100M instruction ceiling |

## Completed Repairs

* Each FFI emulator requests its own insecure environment and loads its own
  shared object.
* Native memory size is 65536 bytes and reset-vector bytes are unsigned.
* Reset no longer invents `A = $AA`, uses the live stack pointer, decrements it
  three times, sets `I`, and completes in seven exposed accesses.
* Absolute operands are decoded little-endian without confusing Lua's status
  return for the byte value.
* Indexed and indirect pointer bytes are treated as unsigned.
* Zero-page indirect pointers wrap at 256, not 255.
* Indexed-indirect and indirect-indexed modes use the operand's zero-page
  pointer rather than register `A`.
* Relative operands are signed.
* Indirect `JMP` implements the NMOS `$xxFF` high-byte wrap quirk.
* Native opcode `$91` now dispatches `STA (zero-page),Y`, rather than the
  indexed-indirect helper used by `$81`.
* Lua `LDY #` now uses immediate addressing and `STX zero-page,Y` uses `Y`.
* `TAY` writes `Y` rather than `X` in both backends.
* Lua derives `N` from bit 7, independent of whether a byte is represented as a
  positive or negative host-language number.
* Lua stack operations wrap within page 1 and consistently unpack memory status
  and values; PC pushes now push `PC`, not `SP`.
* `PHP`/`BRK` synthesize `B` and bit 5 only in the stacked status byte, while
  `PLP`/`RTI` ignore them.
* `JSR` no longer decodes its operand twice in native or as zero-page in Lua;
  `RTS` restores the stacked final-instruction address and advances once.
* `BRK` consumes its padding byte, pushes `PC + 2`, reads both IRQ-vector bytes,
  and round trips through `RTI`.
* `BIT` reads its operand rather than the next program byte.
* Lua `EOR`, `CPY`, `INX`, and `INY` now use the correct operands/registers;
  counter operations wrap at 8 bits.
* Comparisons are unsigned for carry and use the wrapped subtraction for `N`/`Z`.
* Lua opcode registrations `$D9` (`CMP abs,Y`) and `$FE` (`INC abs,X`) no longer
  overwrite `$D8` and `$FD`.
* Lua accumulator shifts now store their results; all shift/rotate paths use
  defined unsigned bytes and capture carry-out before modifying the value.
* Native `LSR` no longer depends on implementation-defined signed right shift,
  and accumulator shift/rotate instructions explicitly report success.

## Addressing Checkpoint

Completed all eight `LDA` encodings and seven `STA` encodings, including:

* zero-page indexed wrap;
* absolute indexed page crossing and 16-bit wrap;
* `(zero-page,X)` pointer wrap;
* `(zero-page),Y` pointer wrap and page crossing;
* unsigned bytes at and above `$80`;
* indirect `JMP ($xxFF)` and backward relative branches as dedicated control-
  flow regressions.

Both backends pass 84 assertions in their shared chip suite at this checkpoint.

## Loads, Stores, and Transfers Checkpoint

Completed every official `LDA`, `LDX`, `LDY`, `STA`, `STX`, `STY`, and register-
transfer encoding. Immediate loads assert `N`/`Z` independently at `$00`, `$7F`,
`$80`, and `$FF`; stores and `TXS` preserve status. Both backends pass 180
assertions in their shared chip suite at this checkpoint.

## Stack and Software Interrupt Checkpoint

Completed the hardware-wrapping stack and its control-flow users:

* `PHA`, `PLA`, `PHP`, and `PLP`, including `N`/`Z`, synthesized `B`/bit 5, and
  status bits ignored on pull;
* push and pull wrapping at `SP = $00/$FF`;
* nested `JSR`/`RTS`, exact return-address byte order, and stack wrapping;
* `BRK` and `RTI` after ordinary stack mechanics are trustworthy.
* Binary `ADC`/`SBC` operands are unsigned, `N`/`Z` derive from the wrapped
  result, and subtraction carry reports no-borrow in both backends.
* Lua now implements NMOS decimal `ADC`/`SBC`; native decimal `ADC` correctly
  derives `N` from the pre-adjust high result and sets carry at the `$100`
  boundary. Both preserve `D` and reproduce the NMOS intermediate flag rules.
* Native indexed address helpers treat high-bit `X` and `Y` values as unsigned;
  `$FB` no longer becomes host integer `-5`.
* Native accumulator `ROR` is a logical shift even when `A` has bit 7 set.
* Lua opcode `$31`, `AND (zero-page),Y`, calls the correct indirect-Y helper.

Nested calls and a complete `BRK -> RTI` round trip are included. Both backends
pass 229 assertions in their shared chip suite at this checkpoint.

## Logic, Comparison, and Counters Checkpoint

Completed the semantic boundary vectors for logic, comparison, and bit
inspection before arithmetic:

* immediate `AND`, `EOR`, and `ORA` with independent `N`/`Z`;
* `CMP`, `CPX`, and `CPY` across less/equal/greater and signed-bit boundaries;
* both `BIT` encodings with operand-derived `N`/`V`, accumulator-derived `Z`,
  and preservation of A;
* every `INC`/`DEC` encoding and register increment/decrement wrapping.

Both backends pass 323 assertions in their shared chip suite. A later encoding-
coverage sweep will run boolean and comparison semantics through every addressing
encoding; their addressing helpers are already independently covered.

## Shift and Rotate Checkpoint

Completed shifts and rotates in accumulator and memory forms:

* `ASL` and `LSR` with shifted-out carry and `$00/$01/$7F/$80/$FF` boundaries;
* `ROL` and `ROR` with both carry-in states;
* every official addressing encoding and read-modify-write destination;
* preservation of unrelated status bits.

All 20 official `ASL`, `LSR`, `ROL`, and `ROR` encodings are covered. Both
backends pass 383 assertions in their shared chip suite.

## Binary Arithmetic Checkpoint

Completed binary arithmetic before touching decimal mode:

* `ADC` and `SBC` over all 256 x 256 operand pairs and both carry-in states;
* independently compute `A`, `N`, `Z`, `C`, and `V` in the test oracle;
* run compact semantic vectors through every official addressing encoding;
* preserve `I` and unrelated modeled flags;
* keep decimal mode disabled throughout this checkpoint.

That is 262,144 arithmetic cases per backend, or 524,288 mirrored cases. Both
backends pass 417 assertions in the shared chip suite; the exhaustive loops
report their first complete mismatch as one compact assertion. On the current
mock run, Lua completed the sweep in 6.90 seconds and native in 2.22 seconds.

## Decimal Arithmetic Checkpoint

NMOS decimal-mode `ADC` and `SBC` are pinned against an independent oracle,
including invalid packed-BCD nibbles and the NMOS-specific flag behavior.

### Decimal Test Sources

The existing `data/6502_functional_test.bin` is the general Klaus Dormann
functional image, not the separate decimal test. Its local SHA-256 is
`fa12bfc761e6f9057e4cc01a665a7b800ff01ae91f598af1e39a1201d01953fd`.

Use Bruce Clark's public-domain decimal test from Klaus's repository as the
primary algorithmic oracle, but do not use its stock configuration unchanged.
For the NMOS target it must be assembled with:

* `cputype = 0`;
* `vld_bcd = 0`, so invalid packed-BCD nibbles are included;
* `chk_a`, `chk_n`, `chk_v`, `chk_z`, and `chk_c` all enabled.

The upstream source defaults `chk_n`, `chk_v`, and `chk_z` to zero. A default
binary therefore does not validate the peculiar NMOS values of those flags.

Use the newer MIT-licensed SingleStepTests 65x02 vectors as a complementary
instruction/bus-state sample, not as the sole arithmetic oracle. Resolve any
disagreement against Bruce Clark's exhaustive algorithm and Visual6502's
transistor-level behavior. Finally, run the separate Klaus decimal program and
the existing general functional image to their documented success endpoints;
merely executing their first instruction remains only a smoke test.

The mirrored in-process oracle now exhausts all 256 x 256 operand pairs and both
carry states for both operations: 262,144 decimal cases per backend, 524,288
total. It validates the accumulator and all of `N`, `V`, `Z`, and `C`, confirms
that `D` is preserved, and includes invalid BCD digits. Both backends pass 419
assertions in the shared chip suite. On the checkpoint run, Lua completed the
decimal sweep in 10.51 seconds and native in 4.41 seconds.

Bruce Clark is credited in the contract and beside the oracle implementation;
his published decimal test is public domain, but its provenance remains
important to the project.

## Flags, Branches, and Klaus Checkpoint

All eight branch conditions are tested both taken and rejected, including
forward and backward page crossings. `CLC`, `SEC`, `CLI`, `SEI`, `CLV`, `CLD`,
and `SED` alter only their named bit, and `NOP` is programmer-state inert.

The former one-instruction Klaus smoke test has been replaced by an opt-in full
integration run. This image enters at `$0400` (its reset vector deliberately
points to the `$37A3` failure trap), succeeds at `$3469`, diagnoses unexpected
self-loops and emulator errors with register/stack state, and stops after 100
million instructions if neither success nor a trap occurs.

The first real run exposed and led to repairs for signed native index registers,
signed native `ROR A`, and Lua's broken `$31` dispatcher. After those fixes:

* Native completes Klaus in 23.98 seconds.
* Lua completes Klaus in 186.91 seconds.
* The ordinary mirrored chip suite passes 31 tests and 514 assertions per
  backend without paying the full-test runtime.

### Lua Dummy-Read Experiment

Lua no longer calls into the memory object for timing-only accesses made by
implied instructions, taken branches, page crossings, BRK's padding byte, and
pre-pop stack cycles. These paths increment `cycles` directly and retain the
corresponding address in `AB`; real opcode, operand, pointer, stack-data, and
vector reads are unchanged. Reset's seven observable accesses remain intact.

The complete Lua Klaus time fell from 186.91 to 182.91 seconds: a 4.00-second,
approximately 2.1% improvement. The optimization is valid but confirms that
real memory traffic and Lua dispatch/helper overhead dominate this workload.

A follow-up load-time code-generation experiment fused all eight `LDA`
addressing modes, direct backing-store reads, and `N`/`Z` updates into generated
handlers. It remained conformant but regressed Klaus to 191.93 seconds, 9.02
seconds slower than the dummy-read baseline. That generated specialization was
removed. Future handler work should use LuaJIT trace/exit evidence rather than
assuming fewer source-level calls necessarily produce better traces.

Profiling then identified the actual dominant cost: the mock had not trusted
`foundation_binary`, so `foundation.com.bit` was the portable Lua fallback.
Approximately 64% of profiler samples were in its `uband`, `to_u32_list`,
`ubor`, public `band`, and `ubxor` functions. With `foundation_binary` trusted
and LuaJIT's native `bit` module active:

* the Lua Klaus run falls from 182.91 to 61.84 seconds (about 66.2% faster);
* exhaustive binary arithmetic falls from 6.48 seconds to 70.49 milliseconds;
* exhaustive decimal arithmetic falls from 10.72 seconds to 111.79 milliseconds.

## Next Checkpoint

Complete the remaining logic/comparison addressing-encoding matrix, then decide
whether to integrate the separate Klaus/Bruce decimal program in addition to
the faster in-process exhaustive oracle.
