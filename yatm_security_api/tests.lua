local Luna = assert(foundation.com.Luna)

local m = assert(yatm.security)

local case = Luna:new("yatm.security")

case:describe("", function (t2)
  t2:test("", function (t3)

  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
