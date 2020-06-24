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
dofile(yatm_core.modpath .. "/tests/util/direction_test.lua")
dofile(yatm_core.modpath .. "/tests/util/number_test.lua")
dofile(yatm_core.modpath .. "/tests/util/string_test.lua")
dofile(yatm_core.modpath .. "/tests/util/string_buf_test.lua")
dofile(yatm_core.modpath .. "/tests/util/table_test.lua")
dofile(yatm_core.modpath .. "/tests/util/value_test.lua")
dofile(yatm_core.modpath .. "/tests/util/bit_test.lua")
