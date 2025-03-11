local mod = foundation_stdlib
local m = foundation.com
local Luna = assert(m.Luna)

local case = Luna:new("yatm_ic.formspec")

case:describe("render_logic_editor/7", function (t2)
  t2:test("", function (t3)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
