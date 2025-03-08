if yatm_oku.OKU and yatm_oku.OKU.has_arch then
  if yatm_oku.OKU:has_arch("oku_forth8") then
    yatm_oku:require("tests/oku/isa/oku_forth8.lua")
  end
  if yatm_oku.OKU:has_arch("oku_forth16") then
    yatm_oku:require("tests/oku/isa/oku_forth16.lua")
  end
  if yatm_oku.OKU:has_arch("oku_forth32") then
    yatm_oku:require("tests/oku/isa/oku_forth32.lua")
  end
else
  minetest.log("warning", "OKU OKU_FORTH* ARCH are not available for testing")
end
