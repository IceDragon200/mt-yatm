if yatm_oku.OKU and yatm_oku.OKU.has_arch and yatm_oku.OKU:has_arch("mos6502") then
  yatm_oku:require("tests/oku/isa/mos_6502/assembler_test.lua")
  yatm_oku:require("tests/oku/isa/mos_6502/builder_test.lua")
  yatm_oku:require("tests/oku/isa/mos_6502/chip_test.lua")
else
  minetest.log("warning", "OKU MOS6502 ARCH is not available for testing")
end

local Luna = assert(foundation.com.Luna)
local OKU = assert(yatm_oku.OKU)
local Buffer = assert(foundation.com.BinaryBuffer or foundation.com.StringBuffer)

local case = Luna:new("yatm_oku.OKU.ISA.MOS6502")

local ARCH = "mos6502"

local function step_and_expect(t, oku, code)
  local steps, err = oku:step(1)
  t:assert_eq(1, steps)
  t:assert_eq(code, err)
end

local function step_ok(t, oku)
  return step_and_expect(t, oku, OKU.isa.MOS6502.OK_CODE)
end

case:describe("step", function (t2)
  t2:test("runs a simple 6502 program", function (t3)
    local oku =
      OKU:new({
        arch = ARCH
      })

    local b = OKU.isa.MOS6502.Builder

    local blob =
      b.lda_imm(0) ..
      b.adc_imm(20)

    oku:w_memory_blob(512, blob)
    oku:w_memory_blob(0xFFFC, "\x00\x02")

    t3:assert_eq(0, oku.memory:r_u8(0xFFFC))
    t3:assert_eq(2, oku.memory:r_u8(0xFFFD))

    t3:assert_eq(512, oku.memory:r_u16(0xFFFC))

    -- reset sequence is roughly 9 steps
    local steps
    local err
    for i = 1,8 do
      step_and_expect(t3, oku, OKU.isa.MOS6502.STARTUP_CODE)
    end
    -- last step of the startup sequence
    step_ok(t3, oku)

    t3:assert_eq(OKU.isa.MOS6502.CPU_STATE_RUN, oku.isa_assigns.chip:get_state())
    t3:assert_eq(2, oku.isa_assigns.chip:get_register_sr())
    t3:assert_eq(512, oku.isa_assigns.chip:get_register_pc())

    step_ok(t3, oku)
    t3:assert_eq(514, oku.isa_assigns.chip:get_register_pc())

    t3:assert_eq(0, oku.isa_assigns.chip:get_register_a())

    step_ok(t3, oku)
    t3:assert_eq(20, oku.isa_assigns.chip:get_register_a())
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
