local Luna = assert(foundation.com.Luna)
local OKU = assert(yatm_oku.OKU)
local Buffer = assert(foundation.com.BinaryBuffer or foundation.com.StringBuffer)

local case = Luna:new("yatm_oku.OKU.ISA.OKU_FORTH8")

local ARCH = "oku_forth8"

case:describe("stack_push/3", function (t2)
  t2:test("can push a value to stack", function (t3)
    local oku =
      OKU:new({
        arch = ARCH
      })

    local ok
    local value
    local err

    ok, err = oku:call_arch("stack_push", 12)
    t3:assert(ok)
    ok, value, err = oku:call_arch("stack_peek")
    t3:assert(ok)
    t3:assert_eq(12, value)

    ok, value, err = oku:call_arch("stack_pop")
    t3:assert(ok)
    t3:assert_eq(12, value)

    ok, value, err = oku:call_arch("stack_peek")
    t3:refute(ok)
    t3:refute(value)

    ok, value, err = oku:call_arch("stack_pop")
    t3:refute(ok)
    t3:refute(value)
  end)
end)

case:describe("step/2", function (t2)
  t2:test("runs a simple oku_forth8 program", function (t3)
    local oku =
      OKU:new({
        arch = ARCH
      })

    local steps
    local ok
    local value
    local err

    local F = yatm_oku.OKU.isa._OKU_FORTH

    oku:call_arch("eval", "1 .")
    steps, err = oku:step(1)
    t3:assert_eq(1, steps)
    t3:assert_eq(err, F.ERR_OK)

    ok, value, err = oku:call_arch("stack_peek")
    t3:assert(ok)
    t3:assert_eq(value, 1)

    steps, err = oku:step(1)
    t3:assert_eq(1, steps)
    t3:assert_eq(err, F.ERR_OK)
    ok, value, err = oku:call_arch("stack_peek")
    t3:refute(ok)
    t3:assert_eq(err, F.ERR_STACK_EMPTY)

    ok, value, err = oku:call_arch("stdout_pop")
    t3:assert(ok)
    t3:assert_eq(value, "1")
  end)
end)

case:describe("bindump/1", function (t2)
  t2:test("can dump a oku_forth8 machine", function (t3)
    local oku =
      OKU:new({
        arch = ARCH
      })

    local stream = Buffer:new('', 'w')

    oku:call_arch("eval", "1 2 3 4 . . . .")
    oku:bindump(stream)

    oku:dispose()

    oku =
      OKU:new({
        arch = ARCH
      })
    stream:reopen('r')
    oku:binload(stream)

    local size = oku:call_arch("execution_stack_size")
    t3:assert_eq(8, size)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
