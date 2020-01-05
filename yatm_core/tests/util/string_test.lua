local Luna = assert(yatm_core.Luna)
local m = yatm_core

local case = Luna:new("yatm_core-util/string")

case:describe("string_bin_encode", function (t2)
  t2:test("can encode a string has a series of binary digits", function (t3)
    t3:assert_eq("00000000" ..
                 "01111111" ..
                 "10000000" ..
                 "11111111", m.string_bin_encode("\x00\x7F\x80\xFF"))

    t3:assert_eq("00000001" ..
                 "00000010" ..
                 "00000100" ..
                 "00001000" ..
                 "00010000" ..
                 "00100000" ..
                 "01000000" ..
                 "10000000", m.string_bin_encode("\x01\x02\x04\x08\x10\x20\x40\x80"))
  end)
end)

case:describe("string_dec_encode", function (t2)
  t2:test("can encode a string has a series of decimal digits", function (t3)
    t3:assert_eq("000127128255", m.string_dec_encode("\x00\x7F\x80\xFF"))
  end)
end)

case:describe("string_hex_encode", function (t2)
  t2:test("can encode a string has a series of hex digits", function (t3)
    t3:assert_eq("007F80FF", m.string_hex_encode("\x00\x7F\x80\xFF"))
  end)
end)

case:describe("string_hex_escape", function (t2)
  t2:test("hex escape a string", function (t3)
    t3:assert_eq("Hello\\x00\\x80\\xFFWorld", m.string_hex_escape("Hello\000\128\255World"))
    t3:assert_eq("2\\x5C3", m.string_hex_escape("2\\3"))
  end)
end)

case:describe("string_hex_unescape", function (t2)
  t2:test("hex unescape a string", function (t3)
    t3:assert_eq("Hello\000\128\255World", m.string_hex_unescape("Hello\\x00\\x80\\xFFWorld"))
    t3:assert_eq("\000\016\128\255", m.string_hex_unescape("\\x00\\x10\\x80\\xFF"))
  end)
end)

case:describe("string_unescape", function (t2)
  t2:test("hex unescape a string", function (t3)
    t3:assert_eq("Hello\000\128\255World", m.string_unescape("Hello\\x00\\x80\\xFFWorld"))
    t3:assert_eq("\000\016\128\255", m.string_unescape("\\x00\\x10\\x80\\xFF"))
  end)

  t2:test("dec unescape a string", function (t3)
    t3:assert_eq("Hello\000\128\255World", m.string_unescape("Hello\\000\\128\\255World"))
    t3:assert_eq("\000\010\128\255", m.string_unescape("\\000\\010\\128\\255"))
  end)
end)

case:describe("string_split", function (t2)
  t2:test("can split a string", function (t3)
    -- split by each character, default behaviour
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("abcde"))
    t3:assert_table_eq({"H", "e", "l", "l", "o"}, m.string_split("Hello"))

    -- split by a char
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("a,b,c,d,e", ","))
    t3:assert_table_eq({"Hello", "dying", "world", "of", "ice"}, m.string_split("Hello,dying,world,of,ice", ","))

    -- split by a word
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("a_splitter_b_splitter_c_splitter_d_splitter_e", "_splitter_"))

    -- split by a char that doesn't exist
    --t3:assert_table_eq({"a|b|c|d|e"}, m.string_split("a|b|c|d|e", "."))

    -- split by a word that doesn't exist
    --t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("a..b..c..d..e", ".."))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
