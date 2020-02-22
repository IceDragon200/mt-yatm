local Luna = assert(yatm_core.Luna)
local m = yatm_oku.OKU.isa.MOS6502.Builder

if not m then
  yatm.warn("OKU.isa.MOS6502.Builder not available for tests")
  return
end

local case = Luna:new("yatm_oku.OKU.isa.MOS6502.Builder")

case:execute()
case:display_stats()
case:maybe_error()
