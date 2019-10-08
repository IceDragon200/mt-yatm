local m = yatm_core
local Luna = assert(yatm_core.Luna)

local case = Luna:new("yatm_core-util")

case:describe("TOML", function (t2)
  t2:describe("encode/1", function (t3)
    t3:test("encodes a simple object", function (t4)
      local result =
        m.TOML.encode({
          a = "hello",
          b = "world",
          c = true,
          d = false,
          e = 12,
        })

      t4:assert_eq([[
a = "hello"
b = "world"
c = true
d = false
e = 12
]], result)
    end)

    t3:test("encodes a nested object", function (t4)
      local result =
        m.TOML.encode({
          root = {
            a = "hello",
            b = "world",
            c = true,
            d = false,
            e = 12,
          },
        })

      t4:assert_eq([[
[root]
a = "hello"
b = "world"
c = true
d = false
e = 12
]], result)
    end)

    t3:test("encodes a object with a unsafe key", function (t4)
      local result =
        m.TOML.encode({
          ["root:other_thing"] = {
            a = "hello",
            b = "world",
            c = true,
            d = false,
            e = 12,
          },
        })

      t4:assert_eq([[
["root:other_thing"]
a = "hello"
b = "world"
c = true
d = false
e = 12
]], result)
    end)
  end)
end)

case:describe("is_blank/1", function (t2)
  t2:test("nil is blank", function (t3)
    t3:assert(m.is_blank(nil))
  end)

  t2:test("an empty string is blank", function (t3)
    t3:assert(m.is_blank(""))
  end)

  t2:test("a string with only whitespaces is not blank, though it should be", function (t3)
    t3:refute(m.is_blank(" "))
    t3:refute(m.is_blank("    "))
  end)

  t2:test("booleans are not blank", function (t3)
    t3:refute(m.is_blank(false))
    t3:refute(m.is_blank(true))
  end)
end)

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

case:describe("table_bury/3", function (t2)
  t2:test("deeply place value into map", function (t3)
    local t = {}

    -- a single key
    m.table_bury(t, {"a"}, 1)

    t3:assert_eq(t["a"], 1)

    m.table_bury(t, {"b", "c"}, 2)
    t3:assert(t["b"])
    t3:assert_eq(t["b"]["c"], 2)
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

case:describe("list_sample/1", function (t2)
  t2:test("randomly select one element from a given list", function (t3)
    local items = {"a", "b", "c", "d"}
    local item = m.list_sample(items)
    t3:assert_in(item, items)
  end)
end)

case:describe("list_get_next/2", function (t2)
  local l = {"abc", "def", "xyz", "123", "456"}

  t2:test("will return the first element given a nil element", function (t3)
    t3:assert_eq(yatm_core.list_get_next(l, nil), "abc")
  end)

  t2:test("will return the next element given an existing element name", function (t3)
    t3:assert_eq(yatm_core.list_get_next(l, "abc"), "def")
    t3:assert_eq(yatm_core.list_get_next(l, "def"), "xyz")
  end)

  t2:test("will loop around the next element given an existing element name", function (t3)
    t3:assert_eq(yatm_core.list_get_next(l, "456"), "abc")
  end)
end)

case:describe("is_table_empty/1", function (t2)
  t2:test("returns true if a table is empty", function (t3)
    t3:assert(m.is_table_empty({}))
    t3:assert(m.is_table_empty({a = nil, b = nil, c = nil}))
  end)

  t2:test("returns false if table contains any pairs", function (t3)
    t3:refute(m.is_table_empty({a = 1}))
    t3:refute(m.is_table_empty({b = 1, c = nil}))
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

case:describe("random_string/1", function (t2)
  t2:test("can generate random strings of specified length", function (t3)
    local s = m.random_string(16)

    t3:assert_eq(#s, 16)
  end)
end)

case:describe("format_pretty_time/1", function (t2)
  t2:test("can format a value greater than an hour", function (t3)
    local result = m.format_pretty_time(3 * 60 * 60 + 60 * 5 + 32)
    t3:assert_eq(result, "03:05:32")

    local result = m.format_pretty_time(12 * 60 * 60 + 60 * 11 + 9)
    t3:assert_eq(result, "12:11:09")
  end)

  t2:test("can format a value greater than a minute", function (t3)
    local result = m.format_pretty_time(60 * 5 + 7)
    t3:assert_eq(result, "05:07")

    local result = m.format_pretty_time(60 * 5 + 32)
    t3:assert_eq(result, "05:32")

    local result = m.format_pretty_time(60 * 32 + 32)
    t3:assert_eq(result, "32:32")
  end)

  t2:test("can format a value less than a minute", function (t3)
    local result = m.format_pretty_time(32)
    t3:assert_eq(result, "32")

    local result = m.format_pretty_time(5)
    t3:assert_eq(result, "05")
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()

dofile(yatm_core.modpath .. "/tests/util/bin_buf_test.lua")
