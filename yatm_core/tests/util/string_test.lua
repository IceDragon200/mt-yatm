local Luna = assert(yatm_core.Luna)
local m = yatm_core

local case = Luna:new("yatm_core-util/string")

case:describe("string_hex_escape", function (t2)
  t2:test("hex escape a string", function (t3)
    t3:assert_eq("Hello\\x00\\x80\\xFFWorld", m.string_hex_escape("Hello\000\128\255World"))
  end)
end)

case:describe("string_hex_unescape", function (t2)
  t2:test("hex unescape a string", function (t3)
    t3:assert_eq("Hello\000\128\255World", m.string_hex_unescape("Hello\\x00\\x80\\xFFWorld"))
    t3:assert_eq("\000\016\128\255", m.string_hex_unescape("\\x00\\x10\\x80\\xFF"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
