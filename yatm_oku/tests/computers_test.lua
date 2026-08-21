local Luna = assert(foundation.com.Luna)
local M = yatm_oku.Computers
local ACTU8_Builder = assert(yatm_oku.OKU.isa.ACTU8.Builder)

local case = Luna:new("yatm_oku.Computers")

case:describe("&new/1", function (t2)
  t2:test("can initialize a new instance an instance of the computers context without a root dir", function (t3)
    local _m = M:new()
  end)
end)

case:describe("#create_computer/2", function (t2)
  t2:test("can create a new computer instance", function (t3)
    local m = M:new()

    local s = m:create_computer("a_secret", {})

    t3:assert(s.id)
    t3:assert_raw_eq(s, m:get_computer(s.id))
  end)
end)

case:describe("#update/2", function (t2)
  t2:test("can update computers", function (t3)
    local m = M:new()
    local s = m:create_computer("a_secret", {
      arch = "actu8",
    })
    s.active = 1

    local chip = s.oku.isa_assigns.chip
    local memory = s.oku.memory

    memory:w_blob(
      0,
      ACTU8_Builder.nop()
      .. ACTU8_Builder.halt()
    )

    m:update(1.0)

    t3:assert_eq(2, chip.pc)
    t3:assert_eq(1, chip.flags.halt)
    t3:assert_eq(true, s.oku:call_arch("is_halted"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
