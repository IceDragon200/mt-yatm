local Luna = assert(yatm_core.Luna)

local case = Luna:new("yatm_oku.OKU.BinaryMemory")

local m = assert(yatm_oku.OKU.BinaryMemory)

case:describe("i8", function (t2)
  t2:test("can address bytes at location", function (t3)
    local mem = m:new(256) -- really small memory for testing
    t3:assert_eq(mem:i8(0), 0)

    mem:w_i8(0, 32)
    t3:assert_eq(mem:i8(0), 32)

    mem:w_i8(255, 16)
    t3:assert_eq(mem:i8(255), 16)
  end)
end)

case:describe("bytes", function (t2)
  t2:test("can retrieve a list of bytes", function (t3)
    local mem = m:new(256)

    mem:w_i8b(0, 'H')
    mem:w_i8b(1, 'E')
    mem:w_i8b(2, 'L')
    mem:w_i8b(3, 'L')
    mem:w_i8b(4, 'O')

    local result = mem:bytes(0, 5)

    t3:assert_table_eq(result, {72, 69, 76, 76, 79})
  end)
end)
case:execute()
case:display_stats()
case:maybe_error()
