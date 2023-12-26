local Luna = assert(foundation.com.Luna)
local m = yatm_data_logic

local case = Luna:new("yatm_data_logic.util")

case:describe("le_encode_u8", function (t2)
  t2:test("always returns a 1 element string", function (t3)
    t3:assert_eq(1, #m.le_encode_u8(0))
  end)

  t2:test("can encode an unsigned 8 bit integer", function (t3)
    t3:assert_eq("\x00", m.le_encode_u8(0))
    t3:assert_eq("\x0F", m.le_encode_u8(15))
    t3:assert_eq("\x10", m.le_encode_u8(16))
    t3:assert_eq("\x7F", m.le_encode_u8(127))
    t3:assert_eq("\x80", m.le_encode_u8(128))
    t3:assert_eq("\xFF", m.le_encode_u8(255))
  end)
end)

case:describe("le_encode_u16", function (t2)
  t2:test("always returns a 2 element string", function (t3)
    t3:assert_eq(2, #m.le_encode_u16(0))
  end)

  t2:test("can encode an unsigned 16 bit integer", function (t3)
    t3:assert_eq("\x00\x00", m.le_encode_u16(0))
    t3:assert_eq("\x0F\x00", m.le_encode_u16(15))
    t3:assert_eq("\x10\x00", m.le_encode_u16(16))
    t3:assert_eq("\x7F\x00", m.le_encode_u16(127))
    t3:assert_eq("\x80\x00", m.le_encode_u16(128))
    t3:assert_eq("\xFF\x00", m.le_encode_u16(255))

    t3:assert_eq("\x00\x01", m.le_encode_u16(256))
    t3:assert_eq("\x0F\x01", m.le_encode_u16(0x010F))
    t3:assert_eq("\xAD\xDE", m.le_encode_u16(0xDEAD))
  end)
end)

case:describe("le_encode_u24", function (t2)
  t2:test("always returns a 3 element string", function (t3)
    t3:assert_eq(3, #m.le_encode_u24(0))
  end)

  t2:test("can encode an unsigned 24 bit integer", function (t3)
    t3:assert_eq("\x00\x00\x00", m.le_encode_u24(0))
    t3:assert_eq("\x0F\x00\x00", m.le_encode_u24(15))
    t3:assert_eq("\x10\x00\x00", m.le_encode_u24(16))
    t3:assert_eq("\x7F\x00\x00", m.le_encode_u24(127))
    t3:assert_eq("\x80\x00\x00", m.le_encode_u24(128))
    t3:assert_eq("\xFF\x00\x00", m.le_encode_u24(255))

    t3:assert_eq("\x00\x01\x00", m.le_encode_u24(256))
    t3:assert_eq("\x0F\x01\x00", m.le_encode_u24(0x010F))
    t3:assert_eq("\xBE\xAD\xDE", m.le_encode_u24(0xDEADBE))
  end)
end)

case:describe("le_encode_u32", function (t2)
  t2:test("always returns a 4 element string", function (t3)
    t3:assert_eq(4, #m.le_encode_u32(0))
  end)

  t2:test("can encode an unsigned 32 bit integer", function (t3)
    t3:assert_eq("\x00\x00\x00\x00", m.le_encode_u32(0))
    t3:assert_eq("\xEF\xBE\xAD\xDE", m.le_encode_u32(0xDEADBEEF))
  end)
end)

case:describe("le_encode_u40", function (t2)
  t2:test("always returns a 5 element string", function (t3)
    t3:assert_eq(5, #m.le_encode_u40(0))
  end)

  t2:test("can encode an unsigned 40 bit integer", function (t3)
    t3:assert_eq("\x00\x00\x00\x00\x00", m.le_encode_u40(0))
    t3:assert_eq("\xEE\xEF\xBE\xAD\xDE", m.le_encode_u40(0xDEADBEEFEE))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
