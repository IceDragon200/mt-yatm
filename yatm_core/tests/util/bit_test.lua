local Luna = assert(yatm_core.Luna)

local bit_modules = {}
for _, bit_module_name in ipairs({"bit", "native_bit", "local_bit"}) do
  local m = yatm[bit_module_name]
  if m then
    bit_modules[bit_module_name] = m
  else
    minetest.log("warning", "yatm." .. bit_module_name .. " is not available for testing")
  end
end

for bit_module_name, m in pairs(bit_modules) do
  local case = Luna:new("yatm-util." .. bit_module_name)

  case:describe("tohex/1", function (t2)
    t2:test("can convert a 32bit integer to a hex string", function (t3)
      t3:assert_eq("deadbeef", m.tohex(0xDEADBEEF))
      t3:assert_eq("fedcba98", m.tohex(0xFEDCBA98))
      t3:assert_eq("ffffffff", m.tohex(-1))
      t3:assert_eq("FFFFFFFF", m.tohex(-1, -8))
    end)
  end)

  case:describe("band/2", function (t2)
    t2:test("can bitwise AND 2 numbers", function (t3)
      t3:assert_eq(0, m.band(0, 0))
      t3:assert_eq(0, m.band(0, 1))
      t3:assert_eq(1, m.band(1, 1))
      t3:assert_eq(0xFF, m.band(0xAAFF, 0xFF))
      t3:assert_eq(0xEF, m.band(0xAAEF, 0xFF))
      t3:assert_eq(0xAA00, m.band(0xAAEF, 0xFF00))
    end)
  end)

  case:describe("bor/2", function (t2)
    t2:test("can bitwise OR 2 numbers", function (t3)
      t3:assert_eq(0, m.bor(0, 0))
      t3:assert_eq(1, m.bor(0, 1))
      t3:assert_eq(1, m.bor(1, 1))
    end)
  end)

  case:describe("bxor/2", function (t2)
    t2:test("can bitwise XOR 2 numbers", function (t3)
      t3:assert_eq(0, m.bxor(0, 0))
      t3:assert_eq(1, m.bxor(0, 1))
      t3:assert_eq(0, m.bxor(1, 1))
    end)
  end)

  case:describe("bnot/1", function (t2)
    t2:test("can bitwise NOT a number", function (t3)
      t3:assert_eq(-1, m.bnot(0))
      t3:assert_eq(0, m.bnot(-1))
    end)
  end)

  case:describe("bswap/2", function (t2)
    t2:test("can swap the byte order of a number", function (t3)
      --t3:assert_eq(-0xDEADBEEF, m.bswap(0xEFBEADDE))
      --t3:assert_eq(0xEFBEADDE, m.bswap(0xDEADBEEF))
      t3:assert_eq(-0x21524111, m.bswap(0xEFBEADDE))
      t3:assert_eq(-0x10415222, m.bswap(0xDEADBEEF))
      t3:assert_eq(-0x10415222, m.bswap(-0x21524111))
    end)
  end)

  case:describe("rshift/2", function (t2)
    t2:test("can bitwise left shift a number", function (t3)
      t3:assert_eq(0, m.rshift(0x0, 1))
      t3:assert_eq(0, m.rshift(0x1, 1))
      t3:assert_eq(1, m.rshift(0x2, 1))
      t3:assert_eq(2, m.rshift(0x4, 1))
      t3:assert_eq(4, m.rshift(0x8, 1))
      t3:assert_eq(8, m.rshift(0x10, 1))
    end)
  end)

  case:describe("lshift/2", function (t2)
    t2:test("can bitwise right shift a number", function (t3)
      t3:assert_eq(0, m.lshift(0x0, 1))
      t3:assert_eq(2, m.lshift(0x1, 1))
      t3:assert_eq(4, m.lshift(0x2, 1))
      t3:assert_eq(8, m.lshift(0x4, 1))
      t3:assert_eq(16, m.lshift(0x8, 1))
      t3:assert_eq(32, m.lshift(0x10, 1))
    end)
  end)

  case:describe("rol/2", function (t2)
    t2:test("can bitwise rotate-left a number", function (t3)
      t3:assert_eq(0x2, m.rol(0x1, 1))
      t3:assert_eq(0x4, m.rol(0x2, 1))
      t3:assert_eq(0x1, m.rol(0x80000000, 1))
    end)
  end)

  case:describe("ror/2", function (t2)
    t2:test("can bitwise rotate-right a number", function (t3)
      t3:assert_eq(0x1, m.ror(0x2, 1))
      t3:assert_eq(0x2, m.ror(0x4, 1))
      t3:assert_eq(-0x80000000, m.ror(0x1, 1))
    end)
  end)

  case:execute()
  case:display_stats()
  case:maybe_error()
end
