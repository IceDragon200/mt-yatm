--
-- YATM OKU - RISC-V
--
local mod = foundation.new_module("yatm_oku_emu_riscv", "0.1.0")

mod:require("lib/oku/isa/riscv.lua")

if yatm_oku.OKU.isa.RISCV then
  yatm_oku.OKU.AVAILABLE_ARCH.rv32i = {
    engine = yatm_oku.OKU.isa.RISCV,
    default_memory_size = 0x20000, --[[ Roughly 128Kb ]]
  }
else
  core.log("warning", "riscv emulation unavailable")
end

if foundation.com.Luna then
  mod:require("tests/oku_test.lua")
end
