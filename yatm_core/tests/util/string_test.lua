local Luna = assert(yatm_core.Luna)
local m = yatm_core

local case = Luna:new("yatm_core-util/string")

case:describe("string_starts_with/2", function (t2)
  t2:test("returns true if the given string starts with the prefix", function (t3)
    t3:assert(m.string_starts_with("Hello, World", "Hello"))
    t3:refute(m.string_starts_with("Hello, World", "Helloo"))
    t3:refute(m.string_starts_with("Hello, World", "World"))
  end)
end)

case:describe("string_ends_with/2", function (t2)
  t2:test("returns true if the given string ends with the postfix", function (t3)
    t3:assert(m.string_ends_with("Hello, World", "World"))
    t3:refute(m.string_ends_with("Hello, World", "Worldo"))
    t3:refute(m.string_ends_with("Hello, World", "Hello"))
  end)
end)

case:describe("string_trim_leading/2", function (t2)
  t2:test("removes the leading specified string", function (t3)
    t3:assert_eq(", World", m.string_trim_leading("Hello, World", "Hello"))
    t3:assert_eq("Hello, World", m.string_trim_leading("Hello, World", "Helloo"))
    t3:assert_eq("Hello, World", m.string_trim_leading("Hello, World", "Greetings"))
  end)
end)

case:describe("string_trim_trailing/2", function (t2)
  t2:test("removes the trailing specified string", function (t3)
    t3:assert_eq("Hello, ", m.string_trim_trailing("Hello, World", "World"))
    t3:assert_eq("Hello, World", m.string_trim_trailing("Hello, World", "Worldo"))
    t3:assert_eq("Hello, World", m.string_trim_trailing("Hello, World", "Galaxy"))
  end)
end)

case:describe("string_hex_pair_to_byte/1", function (t2)
  t2:test("can decode a simple hexpair string to byte", function (t3)
    t3:assert_eq(0, m.string_hex_pair_to_byte("00"))
    t3:assert_eq(10, m.string_hex_pair_to_byte("0A"))
    t3:assert_eq(15, m.string_hex_pair_to_byte("0F"))
    t3:assert_eq(16, m.string_hex_pair_to_byte("10"))
    t3:assert_eq(127, m.string_hex_pair_to_byte("7F"))
    t3:assert_eq(128, m.string_hex_pair_to_byte("80"))
    t3:assert_eq(255, m.string_hex_pair_to_byte("FF"))
  end)
end)

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
    t3:assert_eq("", m.string_dec_encode(""))
    t3:assert_eq("000127128255", m.string_dec_encode("\x00\x7F\x80\xFF"))
  end)
end)

case:describe("string_hex_encode", function (t2)
  t2:test("can encode a string has a series of hex digits", function (t3)
    t3:assert_eq("", m.string_hex_encode(""))
    t3:assert_eq("007F80FF", m.string_hex_encode("\x00\x7F\x80\xFF"))
    t3:assert_eq("DEADBEEF", m.string_hex_encode("\xDE\xAD\xBE\xEF"))
    t3:assert_eq("BACDEF", m.string_hex_encode("\xBA\xCD\xEF"))
  end)

  t2:test("can encode a string has a series of hex digits with a spacer", function (t3)
    t3:assert_eq("", m.string_hex_encode("", " "))
    t3:assert_eq("00 7F 80 FF", m.string_hex_encode("\x00\x7F\x80\xFF", " "))
  end)
end)

case:describe("string_hex_decode", function (t2)
  t2:test("can decode a hex encoded string", function (t3)
    t3:assert_eq("", m.string_hex_decode(""))
    t3:assert_eq("\x00\x7F\x80\xFF", m.string_hex_decode("007F80FF"))
    t3:assert_eq("\x00\x7F\x80\xFF", m.string_hex_decode("007f80ff"))
    t3:assert_eq("\xDE\xAD\xBE\xEF", m.string_hex_decode("DEADBEEF"))
  end)
end)

case:describe("string_hex_escape", function (t2)
  t2:test("hex escape a string", function (t3)
    t3:assert_eq("", m.string_hex_escape(""))
    t3:assert_eq("Hello\\x00\\x80\\xFFWorld", m.string_hex_escape("Hello\000\128\255World"))
    t3:assert_eq("\\x32\\x5C\\x33", m.string_hex_escape("2\\3", "all"))
    t3:assert_eq("2\\\\3", m.string_hex_escape("2\\3", "non-ascii"))
  end)
end)

case:describe("string_hex_unescape", function (t2)
  t2:test("hex unescape a string", function (t3)
    t3:assert_eq("", m.string_hex_unescape(""))
    t3:assert_eq("Hello\000\128\255World", m.string_hex_unescape("Hello\\x00\\x80\\xFFWorld"))
    t3:assert_eq("\000\016\128\255", m.string_hex_unescape("\\x00\\x10\\x80\\xFF"))
  end)
end)

case:describe("string_unescape", function (t2)
  t2:test("hex unescape a string", function (t3)
    t3:assert_eq("", m.string_unescape(""))
    t3:assert_eq("Hello\000\128\255World", m.string_unescape("Hello\\x00\\x80\\xFFWorld"))
    t3:assert_eq("\000\016\128\255", m.string_unescape("\\x00\\x10\\x80\\xFF"))
  end)

  t2:test("dec unescape a string", function (t3)
    t3:assert_eq("", m.string_unescape(""))
    t3:assert_eq("Hello\000\128\255World", m.string_unescape("Hello\\000\\128\\255World"))
    t3:assert_eq("\000\010\128\255", m.string_unescape("\\000\\010\\128\\255"))
  end)
end)

case:describe("string_split", function (t2)
  t2:test("can split a string", function (t3)
    t3:assert_table_eq({}, m.string_split(""))
    t3:assert_table_eq({}, m.string_split("", ""))
    t3:assert_table_eq({}, m.string_split("", ","))
    -- split by each character, default behaviour
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("abcde"))
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("abcde", ""))
    t3:assert_table_eq({"H", "e", "l", "l", "o"}, m.string_split("Hello"))
    t3:assert_table_eq({"H", "e", "l", "l", "o"}, m.string_split("Hello", ""))

    -- split by a char
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("a,b,c,d,e", ","))
    t3:assert_table_eq({"Hello", "dying", "world", "of", "ice"}, m.string_split("Hello,dying,world,of,ice", ","))

    -- split by a word
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("a_splitter_b_splitter_c_splitter_d_splitter_e", "_splitter_"))

    -- split by a char that doesn't exist
    t3:assert_table_eq({"a|b|c|d|e"}, m.string_split("a|b|c|d|e", "%."))

    -- split by a word that doesn't exist
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.string_split("a..b..c..d..e", "%.%."))
  end)

  t2:test("can split a string line by line", function (t3)
    t3:assert_table_eq({}, m.string_split("", "\n"))
    t3:assert_table_eq({"ABC"}, m.string_split("ABC", "\n"))
    t3:assert_table_eq({"A", "B", "C", ""}, m.string_split("A\nB\nC\n", "\n"))
  end)
end)

case:describe("string_sub_join", function (t2)
  t2:test("splits a given string by columns and then joins the lines together", function (t3)
    t3:assert_eq("ABC\nDEF\nGH", m.string_sub_join("ABCDEFGH", 3, "\n"))
  end)
end)

case:describe("string_rsub", function (t2)
  t2:test("can return a substring of string starting from the end", function (t3)
    t3:assert_eq("", m.string_rsub("", 1))
    t3:assert_eq("A", m.string_rsub("A", 1))
    t3:assert_eq("END", m.string_rsub("THE END", 3))
    t3:assert_eq("D", m.string_rsub("D", 2))
  end)
end)

case:describe("string_remove_spaces", function (t2)
  t2:test("removes all spaces, newlines and return characters in string", function (t3)
    t3:assert_eq("ABC", m.string_remove_spaces(" A  B  C"))
    t3:assert_eq("ABC", m.string_remove_spaces(" A \n B \r C   \t"))
  end)
end)

case:describe("binary_splice", function (t2)
  t2:test("can splice a byte into a string", function (t3)
    t3:assert_eq("\x04\x01\x02", m.binary_splice("\x00\x01\x02", 1, 1, 4))
    t3:assert_eq("\x00\x04\x02", m.binary_splice("\x00\x01\x02", 2, 1, 4))
    t3:assert_eq("\x00\x01\x04", m.binary_splice("\x00\x01\x02", 3, 1, 4))
  end)

  t2:test("can splice a string into another string", function (t3)
    t3:assert_eq("\x04\x01\x02", m.binary_splice("\x00\x01\x02", 1, 1, "\x04"))
    t3:assert_eq("\x00\x04\x02", m.binary_splice("\x00\x01\x02", 2, 1, "\x04"))
    t3:assert_eq("\x00\x01\x04", m.binary_splice("\x00\x01\x02", 3, 1, "\x04"))
  end)

  t2:test("will substring the input value to match the requested byte count", function (t3)
    t3:assert_eq("\x04\x01\x02", m.binary_splice("\x00\x01\x02", 1, 1, "\x04\x02\x03"))
    t3:assert_eq("\x00\x04\x02", m.binary_splice("\x00\x01\x02", 2, 1, "\x04\x02\x03"))
    t3:assert_eq("\x00\x01\x04", m.binary_splice("\x00\x01\x02", 3, 1, "\x04\x02\x03"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
