local Luna = assert(foundation.com.Luna)

local case = Luna:new("yatm_oku.OKU.ISA.OKU_FORTH32")

case:execute()
case:display_stats()
case:maybe_error()
