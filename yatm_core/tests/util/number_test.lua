local Luna = assert(yatm_core.Luna)
local m = yatm_core

local case = Luna:new("yatm_core-util/number")


case:describe("number_lerp/3", function (t2)
  t2:test("will perform a linear interpolation between 2 points", function (t3)
    t:assert_eq(5, m.number_lerp(0, 10, 0.5))
    t:assert_eq(80, m.number_lerp(0, 100, 0.8))
    t:assert_eq(25, m.number_lerp(20, 30, 0.5))
  end)
end)

case:describe("number_moveto/3", function (t2)
  t2:test("will apply given amount to first value to eventually match second value", function (t3)
    t:assert_eq(5, m.number_moveto(0, 10, 5))
    t:assert_eq(5, m.number_moveto(10, 0, 5))
    t:assert_eq(6, m.number_moveto(2, 20, 4))
    t:assert_eq(16, m.number_moveto(20, 2, 4))
  end)
end)
