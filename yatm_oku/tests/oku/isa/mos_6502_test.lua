if yatm_oku.OKU and yatm_oku.OKU.has_arch and yatm_oku.OKU:has_arch("mos6502") then
  yatm_oku:require("tests/oku/isa/mos_6502/assembler_test.lua")
  yatm_oku:require("tests/oku/isa/mos_6502/builder_test.lua")
  yatm_oku:require("tests/oku/isa/mos_6502/chip_test.lua")
else
  minetest.log("warning", "OKU MOS6502 ARCH is not available for testing")
end
