local mod = assert(yatm_oku)
local Luna = assert(foundation.com.Luna)
local isa = assert(yatm_oku.OKU.isa.MOS6502)
local subject = assert(isa.LuaChip)
local Memory = assert(yatm_oku.OKU.Memory)

local case = Luna:new(subject.name)

case:describe("#initialize", function (t2)
  t2:test("can initialize a new chip", function (t3)
    -- mod.modpath
    t3:assert(true)

    local chip = subject:new({
      memory = Memory:new(0xFFFF),
    })

    t3:assert(chip)
  end)
end)

local function run_startup(t3, chip)
  t3:assert(chip)

  t3:assert_eq(chip:get_state(), isa.CPU_STATE_RESET)
  t3:assert_eq(chip:step(), isa.STARTUP_CODE) -- 0
  t3:assert_eq(chip:step(), isa.STARTUP_CODE) -- 1
  t3:assert_eq(chip:step(), isa.STARTUP_CODE) -- 2
  t3:assert_eq(chip:step(), isa.STARTUP_CODE) -- 3
  t3:assert_eq(chip:step(), isa.STARTUP_CODE) -- 4
  t3:assert_eq(chip:step(), isa.STARTUP_CODE) -- 5
  t3:assert_eq(chip:step(), isa.STARTUP_CODE) -- 6
  t3:assert_eq(chip:step(), isa.STARTUP_CODE) -- 7
  t3:assert_eq(chip:step(), isa.OK_CODE) -- 8
  t3:assert_eq(chip:get_state(), isa.CPU_STATE_RUN)
end

case:describe("#step", function (t2)
  t2:test("can complete startup sequence", function (t3)
    -- mod.modpath
    local memory = Memory:new(0xFFFF)

    local chip = subject:new({
      memory = memory,
    })

    run_startup(t3, chip)
  end)
end)

case:describe("#step with 6502 test", function (t2)
  t2:test("can execute 6502 tests", function (t3)
    -- https://github.com/Klaus2m5/6502_65C02_functional_tests
    local f = io.open(mod.modpath .. "/data/6502_functional_test.bin", "r")
    local blob = f:read()
    io.close(f)

    local memory = Memory:new(0xFFFF)

    memory:w_blob(0, blob)
    local chip = subject:new({
      memory = memory,
    })

    run_startup(t3, chip)

    print(dump(chip.m_chip))

    t3:assert_eq(chip:step(), isa.OK_CODE)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
