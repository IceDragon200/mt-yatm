local Luna = assert(foundation.com.Luna)
local m = yatm_data_logic

local case = Luna:new("yatm_data_logic.util")

case:describe("encode_u8", function (t2)
  t2:test("can encode a unsigned 8 bit integer", function (t3)
    t3:assert_eq("\x00", m.encode_u8(0))
    t3:assert_eq("\x0F", m.encode_u8(15))
    t3:assert_eq("\x10", m.encode_u8(16))
    t3:assert_eq("\x7F", m.encode_u8(127))
    t3:assert_eq("\x80", m.encode_u8(128))
    t3:assert_eq("\xFF", m.encode_u8(255))
  end)
end)

case:describe("encode_u16", function (t2)
  t2:test("can encode a unsigned 16 bit integer", function (t3)
    t3:assert_eq("\x00\x00", m.encode_u16(0))
    t3:assert_eq("\x0F\x00", m.encode_u16(15))
    t3:assert_eq("\x10\x00", m.encode_u16(16))
    t3:assert_eq("\x7F\x00", m.encode_u16(127))
    t3:assert_eq("\x80\x00", m.encode_u16(128))
    t3:assert_eq("\xFF\x00", m.encode_u16(255))

    t3:assert_eq("\x00\x01", m.encode_u16(256))
    t3:assert_eq("\x0F\x00", m.encode_u16(0x010F))
    t3:assert_eq("\xAD\xDE", m.encode_u16(0xDEAD))
  end)
end)

case:describe("encode_u24", function (t2)
  t2:xtest("", function ()
  end)
end)

case:describe("encode_u32", function (t2)
  t2:xtest("", function ()
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
