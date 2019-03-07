local m = yatm_core
local Luna = assert(yatm_core.Luna)

local case = Luna.new("yatm_core.UI.Form")

case:describe("table_equals/2", function (t2)
  t2:test("compares 2 tables and determines if they're equal", function (t3)
    t3:assert(m.table_equals({a = 1}, {a = 1}))
    t3:refute(m.table_equals({a = 1}, {a = 1, b = 2}))
    t3:refute(m.table_equals({a = 1}, {a = 2}))
    t3:refute(m.table_equals({a = 1}, {b = 1}))
  end)
end)

case:describe("table_intersperse/2", function (t2)
  t2:test("will add spacer item between elements in table", function (t3)
    local t = {"a", "b", "c", "d", "e"}
    local r = m.table_intersperse(t, ",")

    t3:assert_table_eq(r, {"a", ",", "b", ",", "c", ",", "d", ",", "e"})
  end)

  t2:test("will return an empty table given an empty table", function (t3)
    local t = {}
    local r = m.table_intersperse({}, ",")
    t3:assert_table_eq(r, {})
  end)
end)

case:describe("list_concat/*", function (t2)
  t2:test("can concatentate multiple list-like tables together", function (t3)
    local a = {"abc", "def"}
    local b = {"other", "stuff"}
    local c = {1, 2, 3}
    local r = m.list_concat(a, b, c)
    t3:assert_table_eq(r, {"abc", "def", "other", "stuff", 1, 2, 3})
  end)
end)

case:describe("string_starts_with/2", function (t2)
  t2:test("returns true if the given string starts with the prefix", function (t3)
    t3:assert(m.string_starts_with("Hello, World", "Hello"))
    t3:refute(m.string_starts_with("Hello, World", "World"))
  end)
end)

case:describe("string_ends_with/2", function (t2)
  t2:test("returns true if the given string ends with the postfix", function (t3)
    t3:assert(m.string_ends_with("Hello, World", "World"))
    t3:refute(m.string_ends_with("Hello, World", "Hello"))
  end)
end)

case:describe("iodata_to_string/0", function (t2)
  t2:test("can convert a table to a string", function (t3)
    local result = m.iodata_to_string({"Hello", ", ", "World"})
    t3:assert_eq(result, "Hello, World")
  end)

  t2:test("can handle nested tables", function (t3)
    local result = m.iodata_to_string({"(", {"24", ",", "26", ",", "01"}, ")"})
    t3:assert_eq(result, "(24,26,01)")
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
