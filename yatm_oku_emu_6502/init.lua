local mod = foundation.new_module("yatm_oku_emu_6502", "0.1.0")

local insec = core.request_insecure_environment()
if insec then
  mod.ffi = insec.require("ffi")
end

mod:require("lib/oku/isa/mos_6502.lua")

yatm_oku.OKU.AVAILABLE_ARCH.mos6502 = {
  engine = assert(yatm_oku.OKU.isa.MOS6502, "expected a valid MOS6502 engine"),
  default_memory_size = 0x10000, --[[ Roughly 64Kb ]]
}

if foundation.com.Luna then
  mod:require("tests.lua")
end

mod.ffi = nil
