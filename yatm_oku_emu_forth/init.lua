--
-- YATM OKU - Forth
--
local mod = foundation.new_module("yatm_oku_emu_forth", "0.1.0")

mod:require("lib/oku/isa/oku_forth.lua")
mod:require("lib/oku/isa/oku_forth8.lua")
mod:require("lib/oku/isa/oku_forth16.lua")
mod:require("lib/oku/isa/oku_forth32.lua")

yatm_oku.OKU.AVAILABLE_ARCH.oku_forth8 = {
  engine = yatm_oku.OKU.isa.OKU_FORTH8,
  default_memory_size = 0x100, --[[ Roughly 256b ]]
  default_dictionary_size = 0x1000,
}
yatm_oku.OKU.AVAILABLE_ARCH.oku_forth16 = {
  engine = yatm_oku.OKU.isa.OKU_FORTH16,
  default_memory_size = 0x10000, --[[ Roughly 64Kb ]]
  default_dictionary_size = 0x2000,
}
yatm_oku.OKU.AVAILABLE_ARCH.oku_forth32 = {
  engine = yatm_oku.OKU.isa.OKU_FORTH32,
  default_memory_size = 0x10000, --[[ Roughly 64Kb ]]
  default_dictionary_size = 0x4000,
}

if foundation.com.Luna then
  mod:require("tests.lua")
end
