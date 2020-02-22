local Luna = assert(yatm_core.Luna)
local m = yatm_core

local case = Luna:new("yatm_core.value")

case:describe("deep_equals/2", function (t2)
  t2:test("can compare 2 scalar values", function (t3)
    t3:assert(m.deep_equals(0, 0))
    t3:assert(m.deep_equals(12.747, 12.747))
    t3:assert(m.deep_equals("", ""))
    t3:assert(m.deep_equals("Hello", "Hello"))
    t3:assert(m.deep_equals(true, true))

    t3:refute(m.deep_equals(0, 1))
    t3:refute(m.deep_equals(365.334, 7742.486))
    t3:refute(m.deep_equals("", "String"))
    t3:refute(m.deep_equals("Value", "Other"))
    t3:refute(m.deep_equals(true, false))
  end)

  t2:test("will report false for mismatched types", function (t3)
    t3:refute(m.deep_equals(0, "0"))
    t3:refute(m.deep_equals(false, "0"))
    t3:refute(m.deep_equals(false, 0))
  end)

  t2:test("can compare tables (flat)", function (t3)
    t3:assert(m.deep_equals({}, {}))
    t3:assert(m.deep_equals({1}, {1}))
    t3:assert(m.deep_equals({"Hello", "World"}, {"Hello", "World"}))

    t3:refute(m.deep_equals({}, {data = 1}))
    t3:refute(m.deep_equals({1}, {2}))
    t3:refute(m.deep_equals({"Hello", "World"}, {"Hello", "Universe"}))
  end)

  t2:test("can compare nested tables", function (t3)
    t3:assert(m.deep_equals({a = {b = 2}}, {a = {b = 2}}))
    t3:refute(m.deep_equals({a = {b = 2}}, {a = {b = 3}}))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
