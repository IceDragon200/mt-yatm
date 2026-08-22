local Luna = assert(foundation.com.Luna)
local m = yatm_oku.OKU
local Buffer = assert(foundation.com.BinaryBuffer or foundation.com.StringBuffer)

local case = Luna:new("yatm_oku.OKU")

case:describe("bindump/1", function (t2)
  t2:test("can dump a mos6502 machine", function (t3)
    local oku =
      m:new({
        arch = "mos6502"
      })

    local stream = Buffer:new('', 'w')

    oku:bindump(stream)
  end)
end)

case:describe("binload/1", function (t2)
  t2:test("can load a mos6502 machine", function (t3)
    local oku =
      m:new({
        arch = "mos6502",
        label = "awesome label",
      })

    oku.isa_assigns.chip:set_register_a(127)
    oku.isa_assigns.chip:set_register_x(76)
    oku.isa_assigns.chip:set_register_y(32)
    local stream = Buffer:new('', 'w')

    local x_us = core.get_us_time()
    oku:bindump(stream)
    stream:close()
    local y_us = core.get_us_time()

    print("dump.time", y_us - x_us)

    local oku =
      m:new({
        arch = "mos6502",
        label = "awesome label",
      })

    stream:open('r')
    x_us = core.get_us_time()
    oku:binload(stream)
    y_us = core.get_us_time()

    print("load.time", y_us - x_us)

    t3:assert_eq(oku.arch, "mos6502")
    t3:assert_eq(oku.label, "awesome label")
    t3:assert_eq(oku.isa_assigns.chip:get_register_a(), 127)
    t3:assert_eq(oku.isa_assigns.chip:get_register_x(), 76)
    t3:assert_eq(oku.isa_assigns.chip:get_register_y(), 32)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
