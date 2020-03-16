local Luna = assert(yatm.Luna)

local m = assert(yatm.security)

local case = Luna:new("yatm.security")

case:execute()
case:display_stats()
case:maybe_error()
