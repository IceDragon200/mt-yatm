local Luna = assert(yatm_core.Luna)
local m = yatm_core

local case = Luna:new("yatm_core.table")

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


case:describe("list_last/1", function (t2)
  t2:test("returns the last element in the list", function (t3)
    t3:assert_eq(nil, m.list_last({}))
    t3:assert_eq(1, m.list_last({1}))
    t3:assert_eq("abcdef", m.list_last({"zyx", "abcdef"}))
    t3:assert_eq(5, m.list_last({1, 2, 3, 4, 5}))
  end)
end)

case:describe("list_last/2", function (t2)
  t2:test("returns the last n elements in list", function (t3)
    t3:assert_table_eq({}, m.list_last({}, 1))
    t3:assert_table_eq({1}, m.list_last({1}, 1))
    t3:assert_table_eq({2, 3, 4}, m.list_last({1, 2, 3, 4}, 3))
    t3:assert_table_eq({1, 2, 3, 4}, m.list_last({1, 2, 3, 4}, 5))
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

case:execute()
case:display_stats()
case:maybe_error()
