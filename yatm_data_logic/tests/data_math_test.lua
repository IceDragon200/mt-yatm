local Luna = assert(foundation.com.Luna)
local m = yatm_data_logic.data_math

local case = Luna:new("yatm_data_logic.data_math")

local CONFIG = {
  -- determines how long a number can be in bytes this affects normal operations
  byte_size = 16,
  -- the maximum number of elements expected in a vector type
  vector_size = 16,
  -- how many bytes does each element in the vector occupy
  vector_element_byte_size = 1,
}

case:describe("new_number/2", function (t2)
  t2:test("can initialize a byte vector string", function (t3)
    t3:assert_eq(m.new_number("\x00", CONFIG), m.new_number("\x00", CONFIG))
  end)
end)

case:describe("identity/2", function (t2)
  t2:test("can return the first non-zero value", function (t3)
    t3:assert_eq(m.identity("\x00", "\x00", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.identity("\x00", "\x01", CONFIG), m.new_number("\x01", CONFIG))
    t3:assert_eq(m.identity("\x02", "\x01", CONFIG), m.new_number("\x02", CONFIG))
  end)
end)

case:describe("add/2", function (t2)
  t2:test("adds 2 numbers", function (t3)
    t3:assert_eq(m.add("\x00", "\x00", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.add("\x01", "\x01", CONFIG), m.new_number("\x02", CONFIG))
    t3:assert_eq(m.add("\xFF", "\x01", CONFIG), m.new_number("\x00\x01", CONFIG))
    t3:assert_eq(m.add("\xFF", "\x02", CONFIG), m.new_number("\x01\x01", CONFIG))
    t3:assert_eq(m.add("\xFF\x00", "\x00\x02", CONFIG), m.new_number("\xFF\x02", CONFIG))
  end)
end)

case:describe("subtract/2", function (t2)
  t2:test("subtracts 2 numbers", function (t3)
    t3:assert_eq(m.subtract("\x00", "\x00", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.subtract("\x01", "\x01", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.subtract("\xFF", "\x01", CONFIG), m.new_number("\xFE", CONFIG))
    t3:assert_eq(m.subtract("\xFF\x01", "\x01", CONFIG), m.new_number("\xFE\x01", CONFIG))
    t3:assert_eq(m.subtract("\x00\x01", "\x01", CONFIG), m.new_number("\xFF", CONFIG))
  end)
end)

case:describe("multiply/2", function (t2)
  t2:test("multiples 2 numbers", function (t3)
    t3:assert_eq(m.multiply("\x00", "\x00", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.multiply("\x02", "\x04", CONFIG), m.new_number("\x08", CONFIG))
    t3:assert_eq(m.multiply("\x10", "\x10", CONFIG), m.new_number("\x00\x01", CONFIG))
    t3:assert_eq(m.multiply("\x11", "\x10", CONFIG), m.new_number("\x10\x01", CONFIG))
  end)
end)

case:describe("divide/2", function (t2)
  t2:test("divide 2 numbers", function (t3)
    t3:assert_eq(m.divide("\x00", "\x00", CONFIG), m.new_number(nil, CONFIG, "\xFF"))
    t3:assert_eq(m.divide("\x08", "\x02", CONFIG), m.new_number("\x04", CONFIG))
    t3:assert_eq(m.divide("\x00\x01", "\x02", CONFIG), m.new_number("\x80", CONFIG))
  end)
end)

case:describe("modulo/2", function (t2)
  t2:test("modulo 2 numbers", function (t3)
    t3:assert_eq(m.modulo("\x00", "\x00", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.modulo("\x08", "\x02", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.modulo("\x07", "\x02", CONFIG), m.new_number("\x01", CONFIG))
  end)
end)

case:describe("max/2", function (t2)
  t2:test("determines the largest number between operands", function (t3)
    t3:assert_eq(m.max("\x00", "\x00", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.max("\x01", "\x02", CONFIG), m.new_number("\x02", CONFIG))
    t3:assert_eq(m.max("\xFF", "\x00\x01", CONFIG), m.new_number("\x00\x01", CONFIG))
  end)
end)

case:describe("min/2", function (t2)
  t2:test("determines the smallest number between operands", function (t3)
    t3:assert_eq(m.min("\x00", "\x00", CONFIG), m.new_number("\x00", CONFIG))
    t3:assert_eq(m.min("\x01", "\x02", CONFIG), m.new_number("\x01", CONFIG))
    t3:assert_eq(m.min("\xFF", "\x00\x01", CONFIG), m.new_number("\xFF", CONFIG))
  end)
end)

case:describe("identity_vector/2", function (t2)
  t2:test("returns all existing values between vectors", function (t3)
  end)
end)

case:describe("add_vector/2", function (t2)
  t2:test("add all existing values in vectors", function (t3)
  end)
end)

case:describe("subtract_vector/2", function (t2)
  t2:test("subtracts all existing values in vectors", function (t3)
  end)
end)

case:describe("multiply_vector/2", function (t2)
  t2:test("multiplies all existing values in vectors", function (t3)
  end)
end)

case:describe("divide_vector/2", function (t2)
  t2:test("divide all existing values in vectors", function (t3)
  end)
end)

case:describe("max_vector/2", function (t2)
  t2:test("determines the max values in vectors", function (t3)
  end)
end)

case:describe("min_vector/2", function (t2)
  t2:test("determines the min values in vectors", function (t3)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()

error("FLUNK")
