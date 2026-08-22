local Luna = assert(foundation.com.Luna)
local m = yatm_oku.OKU
local Buffer = assert(foundation.com.BinaryBuffer or foundation.com.StringBuffer)

if not m then
  yatm.warn("OKU not available for tests")
  return
end

local case = Luna:new("yatm_oku.OKU")

case:execute()
case:display_stats()
case:maybe_error()
