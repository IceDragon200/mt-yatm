local Luna = assert(yatm_core.Luna)
local m = yatm_core.StringBuf

local case = Luna:new("yatm_core.StringBuf")

case:describe(":initialize/2", function (t2)
  t2:test("can initialize a new string buffer in read mode", function (t3)
    local strbuf = m:new("", "r")
  end)

  t2:test("can initialize a new string buffer in write mode", function (t3)
    local strbuf = m:new("", "w")
  end)

  t2:test("can initialize a new string buffer in read-write mode", function (t3)
    local strbuf = m:new("", "rw")
  end)

  t2:test("can initialize a new string buffer in append mode", function (t3)
    local strbuf = m:new("", "a")
  end)
end)

case:describe(":size/0", function (t2)
  t2:test("reports correct buffer size", function (t3)
    local strbuf = m:new("", "r")

    t3:assert_eq(0, strbuf:size())

    local strbuf = m:new("Buffer Data", "r")

    t3:assert_eq(11, strbuf:size())

    local strbuf = m:new("\x00\x00\x00\x00", "r")

    t3:assert_eq(4, strbuf:size())
  end)
end)

case:describe(":isEOF/0", function (t2)
  t2:test("reports true if the cursor exceeds the buffer size (in read mode)", function (t3)
    local strbuf = m:new("", "r")
    t3:assert(strbuf:isEOF())

    local strbuf = m:new("Data", "r")
    t3:refute(strbuf:isEOF())

    local strbuf = m:new("Other data", "r")
    strbuf:walk(5)
    t3:refute(strbuf:isEOF())

    strbuf:walk(5)
    t3:assert(strbuf:isEOF())
  end)
end)

case:describe(":tell/0", function (t2)
  t2:test("reports current cursor position", function (t3)
    local strbuf = m:new("Data", "r")

    t3:assert_eq(1, strbuf:tell())
    strbuf:walk(2)
    t3:assert_eq(3, strbuf:tell())
  end)
end)

case:describe(":rewind/0", function (t2)
  t2:test("resets cursor to 1", function (t3)
    local strbuf = m:new("Data", "a")
    t3:assert_eq(5, strbuf:tell())
    strbuf:rewind()
    t3:assert_eq(1, strbuf:tell())
  end)
end)

case:describe(":scan_until/1", function (t2)
  t2:test("returns all string data until match (inclusive)", function (t3)
    local strbuf = m:new("Data ; comment of some kind", "r")
    local data = strbuf:scan_until(";")

    t3:assert_eq("Data ;", data)
    t3:assert_eq(" c", strbuf:peek(2))
  end)

  t2:test("can scan until end of line", function (t3)
    local strbuf = m:new("Data\nOther", "r")

    t3:assert_eq("Data\n", strbuf:scan_until("\n"))
    t3:assert_eq("Ot", strbuf:peek(2))
  end)

  t2:test("can scan until end of string", function (t3)
    local strbuf = m:new("Data", "r")

    t3:assert_eq("Data", strbuf:scan_until("$"))
  end)
end)

case:describe(":scan_upto/1", function (t2)
  t2:test("returns all string data until match (exclusive)", function (t3)
    local strbuf = m:new("Data ; comment of some kind", "r")
    local data = strbuf:scan_upto(";")

    t3:assert_eq("Data ", data)
    t3:assert_eq("; c", strbuf:peek(3))
  end)

  t2:test("can scan until end of line", function (t3)
    local strbuf = m:new("Data\nOther", "r")

    t3:assert_eq("Data", strbuf:scan_upto("\n"))
    t3:assert_eq("\nO", strbuf:peek(2))
  end)
end)

case:describe(":scan_while/1", function (t2)
  t2:test("can scan all data while pattern matches", function (t3)
    local strbuf = m:new("DADADADABADA", "r")

    local data = strbuf:scan_while("DA")
    t3:assert_eq("DADADADA", data)

    local data = strbuf:scan_while("BA")
    t3:assert_eq("BA", data)

    local data = strbuf:read()
    t3:assert_eq("DA", data)
  end)
end)

case:describe(":read/0", function (t2)
  t2:test("reads everything from cursor to end", function (t3)
    local strbuf = m:new("Data ; comment of some kind", "r")

    strbuf:scan_upto(";")
    t3:assert_eq("; comment of some kind", strbuf:read())
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
