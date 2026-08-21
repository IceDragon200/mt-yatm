# YATM OKU Emulation 6502

Adds the MOS6502 modules for OKU allowing players to program and execute programs in 6502 assembly.

This module provides the assembler, and runtime for 6502 binary code.

See [the MOS 6502 emulator contract](docs/mos6502.md) for the target machine
behavior, opcode map, implementation references, and conformance plan.
Current repair and test status is tracked in
[the conformance progress ledger](docs/conformance-progress.md).

## Full Klaus Functional Test

The bundled Klaus Dormann image is intentionally opt-in because it takes about
three minutes on `LuaChip`. From `minetest_mock`, run:

```sh
YATM_OKU_6502_KLAUS=1 \
  ./run.sh --trusted-mods foundation_binary,yatm_oku,yatm_oku_emu_6502 --steps 0
```

Trusting `foundation_binary` lets it load LuaJIT's native `bit` module. Without
that permission it uses the portable Lua fallback, which is conformant but
increases the Lua Klaus time from about 62 seconds to about three minutes.

This runs the image against every available backend. To isolate one backend,
also set `YATM_OKU_6502_KLAUS_BACKEND` to either
`yatm_oku.OKU.isa.MOS6502.LuaChip` or
`yatm_oku.OKU.isa.MOS6502.NativeChip`.

The bundled image uses a monitor-style configuration: `$0400` is its test entry
and `$3469` is its success loop. Its reset vector deliberately enters a failure
trap, so the integration harness sets the documented entry explicitly.
