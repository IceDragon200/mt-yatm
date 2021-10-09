if yatm_oku.OKU:has_arch("mos6502") then
  dofile(yatm_oku.modpath .. "/tests/oku/isa/mos_6502/builder_test.lua")
  dofile(yatm_oku.modpath .. "/tests/oku/isa/mos_6502/assembler_test.lua")
else
  minetest.log("warning", "OKU MOS6502 ARCH is not available for testing")
end
