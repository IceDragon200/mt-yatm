local Luna = assert(foundation.com.Luna)
local ACTU8_Builder = assert(yatm_oku.OKU.isa.ACTU8.Builder)
local OKU = assert(yatm_oku.OKU)

local case = Luna:new("yatm_oku.OKU.isa.ACTU8")
case:describe("#initialize/1", function (t2)
  t2:test("OKU initializes the machine correctly", function (t3)
    local oku = OKU:new({
      arch = "actu8"
    })
    local chip = oku.isa_assigns.chip

    t3:assert_eq("actu8", oku.arch)
    t3:assert_eq(0x800, oku.memory:size())

    oku.memory:w_blob(
      0,
      ACTU8_Builder.nop()
      .. ACTU8_Builder.halt()
    )

    oku:step(2)
    t3:assert_eq(true, oku:call_arch("is_halted"))
    t3:assert_eq(2, chip.pc)
  end)
end)

case:describe("fuzz", function (t2)
  local ITERATIONS = 2048

  t2:test("add <addr8>", function (t3)
    local oku = OKU:new({
      arch = "actu8"
    })
    local chip = oku.isa_assigns.chip
    local memory = oku.memory

    for i = 1,ITERATIONS do
      local addr8 = math.random(256) - 1
      local value = math.random(256) - 1
      oku:reset()
      memory:w_blob(
        0,
        ACTU8_Builder.add(addr8)
        .. ACTU8_Builder.ldi(255)
        .. ACTU8_Builder.add(addr8)
      )
      memory:w_u8(
        memory:size() - 512 + addr8,
        value
      )
      t3:assert_eq(0, chip.a)
      t3:assert_eq(0, chip.pc)

      local zero = 0
      local carry = 0
      oku:step(1)
      if chip.a == 0 then
        zero = 1
      else
        zero = 0
      end
      t3:assert_eq(value, chip.a)
      t3:assert_eq(2, chip.pc)
      t3:assert_matches(chip.flags, {
        borrow = 0,
        carry = carry,
        zero = zero,
      })
      oku:step(2)
      local a = value + 255
      zero = 0
      if chip.a == 0 then
        zero = 1
      else
        zero = 0
      end
      if a > 255 then
        carry = 1
      else
        carry = 0
      end
      t3:assert_eq(a % 256, chip.a)
      t3:assert_matches(chip.flags, {
        borrow = 0,
        carry = carry,
        zero = zero,
      })
      t3:assert_eq(6, chip.pc)
    end
  end)

  t2:test("sub <addr8>", function (t3)
    local oku = OKU:new({
      arch = "actu8"
    })
    local chip = oku.isa_assigns.chip
    local memory = oku.memory

    for i = 1,ITERATIONS do
      local addr8 = math.random(256) - 1
      local value = math.random(256) - 1
      oku:reset()
      memory:w_blob(
        0,
        ""
        .. ACTU8_Builder.ldi(255)
        .. ACTU8_Builder.sub(addr8)
        .. ACTU8_Builder.ldi(0)
        .. ACTU8_Builder.sub(addr8)
      )
      memory:w_u8(
        memory:size() - 512 + addr8,
        value
      )
      t3:assert_eq(0, chip.a)
      t3:assert_eq(0, chip.pc)

      local zero = 0
      local borrow = 0
      oku:step(2)
      if chip.a == 0 then
        zero = 1
      else
        zero = 0
      end
      t3:assert_eq(255 - value, chip.a)
      t3:assert_eq(4, chip.pc)
      t3:assert_matches(chip.flags, {
        carry = 0,
        borrow = borrow,
        zero = zero,
      })
      oku:step(2)
      local a = 0 - value
      zero = 0
      if chip.a == 0 then
        zero = 1
      else
        zero = 0
      end
      if a < 0 then
        borrow = 1
      else
        borrow = 0
      end
      t3:assert_eq(a % 256, chip.a)
      t3:assert_matches(chip.flags, {
        borrow = 0,
        borrow = borrow,
        zero = zero,
      })
      t3:assert_eq(8, chip.pc)
    end
  end)

  t2:test("cmp <addr8>", function (t3)
    local oku = OKU:new({
      arch = "actu8"
    })
    local chip = oku.isa_assigns.chip
    local memory = oku.memory

    for i = 1,ITERATIONS do
      local addr8 = math.random(256) - 1
      local a = math.random(256) - 1
      local b = math.random(256) - 1
      oku:reset()
      memory:w_blob(
        0,
        ""
        .. ACTU8_Builder.ldi(a)
        .. ACTU8_Builder.cmp(addr8)
      )
      memory:w_u8(
        memory:size() - 512 + addr8,
        b
      )
      t3:assert_eq(0, chip.a)
      t3:assert_eq(0, chip.pc)

      local zero = 0
      local borrow = 0
      local carry = 0
      oku:step(2)
      if a == b then
        zero = 1
      else
        zero = 0
      end
      if a < b then
        borrow = 1
      else
        borrow = 0
      end
      if a > b then
        carry = 1
      else
        carry = 0
      end
      t3:assert_eq(a, chip.a)
      t3:assert_eq(4, chip.pc)
      t3:assert_matches(chip.flags, {
        carry = carry,
        borrow = borrow,
        zero = zero,
      })
    end
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()

error("nope")
