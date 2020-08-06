local Luna = assert(foundation.com.Luna)

local case = Luna:new("yatm_oku.OKU.Memory")

local m = assert(yatm_oku.OKU.Memory)

case:describe("adjust_and_check_bounds", function (t2)
  t2:test("will correctly adjust the given index to match internal", function (t3)
    local mem = m:new(256) -- really small memory for testing

    local i, o

    -- byte
    i, o = mem:adjust_and_check_bounds(0, 1)
    t3:assert_eq(i, 0)
    t3:assert_eq(o, 0)

    i, o = mem:adjust_and_check_bounds(1, 1)
    t3:assert_eq(i, 0)
    t3:assert_eq(o, 1)

    i, o = mem:adjust_and_check_bounds(2, 1)
    t3:assert_eq(i, 0)
    t3:assert_eq(o, 2)

    i, o = mem:adjust_and_check_bounds(3, 1)
    t3:assert_eq(i, 0)
    t3:assert_eq(o, 3)

    i, o = mem:adjust_and_check_bounds(4, 1)
    t3:assert_eq(i, 1)
    t3:assert_eq(o, 0)

    i, o = mem:adjust_and_check_bounds(255, 1)
    t3:assert_eq(i, 63)
    t3:assert_eq(o, 3)

    -- short / 2 bytes
    i, o = mem:adjust_and_check_bounds(0, 2)
    t3:assert_eq(i, 0)
    t3:assert_eq(o, 0)

    i, o = mem:adjust_and_check_bounds(1, 2)
    t3:assert_eq(i, 0)
    t3:assert_eq(o, 1)

    i, o = mem:adjust_and_check_bounds(2, 2)
    t3:assert_eq(i, 1)
    t3:assert_eq(o, 0)

    -- int / 4 bytes
    i, o = mem:adjust_and_check_bounds(0, 4)
    t3:assert_eq(i, 0)
    t3:assert_eq(o, 0)

    i, o = mem:adjust_and_check_bounds(1, 4)
    t3:assert_eq(i, 1)
    t3:assert_eq(o, 0)

    i, o = mem:adjust_and_check_bounds(2, 4)
    t3:assert_eq(i, 2)
    t3:assert_eq(o, 0)
  end)
end)

case:describe("i8", function (t2)
  t2:test("can address bytes at location", function (t3)
    local mem = m:new(256) -- really small memory for testing

    t3:assert_eq(mem:i8(0), 0)
    mem:w_i8(0, 32)
    t3:assert_eq(mem:i8(0), 32)

    t3:assert_eq(mem:i8(1), 0)
    mem:w_i8(1, 87)
    t3:assert_eq(mem:i8(0), 32)
    t3:assert_eq(mem:i8(1), 87)

    t3:assert_eq(mem:i8(7), 0)
    mem:w_i8(7, 120)
    t3:assert_eq(mem:i8(0), 32)
    t3:assert_eq(mem:i8(1), 87)
    t3:assert_eq(mem:i8(7), 120)

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
