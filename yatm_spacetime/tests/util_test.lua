local m = yatm_spacetime
local Luna = assert(foundation.com.Luna)

local case = Luna:new("yatm_spacetime")

case:describe("generate_address/0", function (t2)
  t2:test("can generate a spacetime address", function (t3)
    t3:assert(m.generate_address())
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
