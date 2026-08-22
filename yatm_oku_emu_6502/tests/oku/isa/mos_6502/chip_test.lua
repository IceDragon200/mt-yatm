local mod = assert(yatm_oku_emu_6502)
local path_join = assert(foundation.com.path_join)
local bit = assert(foundation.com.bit)

local Luna = assert(foundation.com.Luna)
local isa = assert(yatm_oku.OKU.isa.MOS6502)
local Memory = assert(yatm_oku.OKU.Memory)

local subjects = {
  assert(isa.LuaChip),
}
if isa.NativeChip then
  subjects[#subjects + 1] = isa.NativeChip
end

local function new_chip(subject, memory)
  local chip = subject:new()
  chip:set_memory(memory)
  return chip
end

local function write_bytes(memory, address, bytes)
  for index, value in ipairs(bytes) do
    memory:w_u8(address + index - 1, value)
  end
end

local function new_running_chip(subject, bytes)
  local memory = Memory:new(0x10000)
  local chip = new_chip(subject, memory)
  chip:set_state(isa.CPU_STATE_RUN)
  chip:set_register_pc(0x0200)
  write_bytes(memory, 0x0200, bytes)
  return chip, memory
end

local function run_startup(t3, chip)
  t3:assert(chip)

  t3:assert_eq(isa.CPU_STATE_RESET, chip:get_state())
  t3:assert_eq(isa.STARTUP_CODE, chip:step()) -- 0
  t3:assert_eq(isa.STARTUP_CODE, chip:step()) -- 1
  t3:assert_eq(isa.STARTUP_CODE, chip:step()) -- 2
  t3:assert_eq(isa.STARTUP_CODE, chip:step()) -- 3
  t3:assert_eq(isa.STARTUP_CODE, chip:step()) -- 4
  t3:assert_eq(isa.STARTUP_CODE, chip:step()) -- 5
  t3:assert_eq(isa.OK_CODE, chip:step()) -- 6
  t3:assert_eq(isa.CPU_STATE_RUN, chip:get_state())
end

local data_filename = path_join(mod.modpath, "/data/6502_functional_test.bin")
local functional_test_blob
local file = io.open(data_filename, "rb")
if file then
  functional_test_blob = file:read("*a")
  file:close()
end
local run_full_functional_test = os.getenv("YATM_OKU_6502_KLAUS") == "1"
local functional_test_backend = os.getenv("YATM_OKU_6502_KLAUS_BACKEND")

for _, subject in ipairs(subjects) do
  local case = Luna:new(subject._name)

  case:describe("#initialize", function (t2)
    t2:test("can initialize a new chip", function (t3)
      local chip = new_chip(subject, Memory:new(0x10000))
      t3:assert(chip)
      chip:dispose()
    end)
  end)

  case:describe("#step (startup)", function (t2)
    t2:test("can complete startup sequence", function (t3)
      local chip = new_chip(subject, Memory:new(0x10000))
      run_startup(t3, chip)
      chip:dispose()
    end)

    t2:test("loads the reset vector and performs NMOS reset side effects", function (t3)
      local memory = Memory:new(0x10000)
      memory:w_u8(isa.RESET_VECTOR_PTR, 0xCD)
      memory:w_u8(isa.RESET_VECTOR_PTR + 1, 0xAB)

      local chip = new_chip(subject, memory)
      chip:set_register_sp(0x80)
      chip:set_register_a(0x5A)
      chip:set_register_x(0x6B)
      chip:set_register_y(0x7C)
      chip:set_register_sr(0x00)

      run_startup(t3, chip)

      t3:assert_eq(0xABCD, chip:get_register_pc())
      t3:assert_eq(0x7D, chip:get_register_sp())
      t3:assert_eq(0x5A, chip:get_register_a())
      t3:assert_eq(0x6B, chip:get_register_x())
      t3:assert_eq(0x7C, chip:get_register_y())
      t3:assert_eq(0x04, bit.band(chip:get_register_sr(), 0x04))
      chip:dispose()
    end)
  end)

  case:describe("#step (opcodes)", function (t2)
    t2:test("addresses every LDA operand mode", function (t3)
      local vectors = {
        { "immediate",          { 0xA9, 0x42 },       0x42,   0x0202 },
        { "zero page",          { 0xA5, 0x80 },       0x0080, 0x0202 },
        { "zero page,X wrap",   { 0xB5, 0xF0 },       0x0010, 0x0202, x = 0x20 },
        { "absolute",           { 0xAD, 0x34, 0x12 }, 0x1234, 0x0203 },
        { "absolute,X crossing",{ 0xBD, 0xF0, 0x12 }, 0x1310, 0x0203, x = 0x20 },
        { "absolute,Y crossing",{ 0xB9, 0xF0, 0x12 }, 0x1310, 0x0203, y = 0x20 },
        { "(zero page,X) wrap", { 0xA1, 0xF8 },       0x3456, 0x0202, x = 0x08,
          pointer = { 0x00, 0x56, 0x34 } },
        { "(zero page),Y wrap", { 0xB1, 0xFF },       0x1310, 0x0202, y = 0x20,
          pointer = { 0xFF, 0xF0, 0x12 } },
      }

      for _, vector in ipairs(vectors) do
        local chip, memory = new_running_chip(subject, vector[2])
        if vector.x then chip:set_register_x(vector.x) end
        if vector.y then chip:set_register_y(vector.y) end
        if vector.pointer then
          local address, lo, hi = unpack(vector.pointer)
          memory:w_u8(address, lo)
          memory:w_u8((address + 1) % 0x100, hi)
        end
        memory:w_u8(vector[3], 0x42)

        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        t3:assert_eq(0x42, bit.band(chip:get_register_a(), 0xFF), vector[1])
        t3:assert_eq(vector[4], chip:get_register_pc(), vector[1])
        chip:dispose()
      end
    end)

    t2:test("addresses every STA operand mode", function (t3)
      local vectors = {
        { "zero page",          { 0x85, 0x80 },       0x0080 },
        { "zero page,X wrap",   { 0x95, 0xF0 },       0x0010, x = 0x20 },
        { "absolute",           { 0x8D, 0x34, 0x12 }, 0x1234 },
        { "absolute,X crossing",{ 0x9D, 0xF0, 0x12 }, 0x1310, x = 0x20 },
        { "absolute,Y crossing",{ 0x99, 0xF0, 0x12 }, 0x1310, y = 0x20 },
        { "(zero page,X) wrap", { 0x81, 0xF8 },       0x3456, x = 0x08,
          pointer = { 0x00, 0x56, 0x34 } },
        { "(zero page),Y wrap", { 0x91, 0xFF },       0x1310, y = 0x20,
          pointer = { 0xFF, 0xF0, 0x12 } },
      }

      for _, vector in ipairs(vectors) do
        local chip, memory = new_running_chip(subject, vector[2])
        chip:set_register_a(0xA5)
        if vector.x then chip:set_register_x(vector.x) end
        if vector.y then chip:set_register_y(vector.y) end
        if vector.pointer then
          local address, lo, hi = unpack(vector.pointer)
          memory:w_u8(address, lo)
          memory:w_u8((address + 1) % 0x100, hi)
        end

        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        t3:assert_eq(0xA5, memory:r_u8(vector[3]), vector[1])
        chip:dispose()
      end
    end)

    t2:test("treats high-bit index registers as unsigned addresses", function (t3)
      local vectors = {
        { "absolute,X", { 0xBD, 0x02, 0x01 }, 0x01FD, x = 0xFB },
        { "absolute,Y", { 0xB9, 0x02, 0x01 }, 0x01FD, y = 0xFB },
        { "zero page,X", { 0xB5, 0x05 }, 0x0000, x = 0xFB },
        { "(zero page,X)", { 0xA1, 0x05 }, 0x1234, x = 0xFB,
          pointer = { 0x00, 0x34, 0x12 } },
        { "(zero page),Y", { 0xB1, 0x20 }, 0x01FD, y = 0xFB,
          pointer = { 0x20, 0x02, 0x01 } },
      }
      for _, vector in ipairs(vectors) do
        local chip, memory = new_running_chip(subject, vector[2])
        if vector.x then chip:set_register_x(vector.x) end
        if vector.y then chip:set_register_y(vector.y) end
        if vector.pointer then
          local address, lo, hi = unpack(vector.pointer)
          memory:w_u8(address, lo)
          memory:w_u8((address + 1) % 0x100, hi)
        end
        memory:w_u8(vector[3], 0x42)
        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        t3:assert_eq(0x42, bit.band(chip:get_register_a(), 0xFF), vector[1])
        chip:dispose()
      end
    end)

    t2:test("jumps directly and through the NMOS indirect-page wrap", function (t3)
      local chip = new_running_chip(subject, { 0x4C, 0xCD, 0xAB })
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0xABCD, chip:get_register_pc())
      chip:dispose()

      local memory
      chip, memory = new_running_chip(subject, { 0x6C, 0xFF, 0x12 })
      memory:w_u8(0x12FF, 0x78)
      memory:w_u8(0x1200, 0x56)
      memory:w_u8(0x1300, 0x99) -- must not supply the high byte on NMOS
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x5678, chip:get_register_pc())
      chip:dispose()
    end)

    t2:test("uses a signed relative branch displacement", function (t3)
      local chip = new_running_chip(subject, { 0xD0, 0xFC }) -- BNE -4
      chip:set_register_sr(0x00)
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x01FE, chip:get_register_pc())
      chip:dispose()

      chip = new_running_chip(subject, { 0xD0, 0xFC })
      chip:set_register_sr(0x02)
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0202, chip:get_register_pc())
      chip:dispose()
    end)

    t2:test("takes and rejects every conditional branch", function (t3)
      local branches = {
        { "BPL", 0x10, 0x80 }, { "BMI", 0x30, 0x80, true },
        { "BVC", 0x50, 0x40 }, { "BVS", 0x70, 0x40, true },
        { "BCC", 0x90, 0x01 }, { "BCS", 0xB0, 0x01, true },
        { "BNE", 0xD0, 0x02 }, { "BEQ", 0xF0, 0x02, true },
      }

      for _, branch in ipairs(branches) do
        for flag_set = 0, 1 do
          local chip = new_running_chip(subject, { branch[2], 0x05 })
          local sr = flag_set == 1 and branch[3] or 0
          chip:set_register_sr(sr)
          local taken = (flag_set == 1) == (branch[4] == true)
          local label = branch[1] .. (taken and " taken" or " not taken")
          t3:assert_eq(isa.OK_CODE, chip:step(), label)
          t3:assert_eq(taken and 0x0207 or 0x0202, chip:get_register_pc(), label)
          t3:assert_eq(sr, bit.band(chip:get_register_sr(), 0xFF), label)
          chip:dispose()
        end
      end
    end)

    t2:test("branches across a page in both directions", function (t3)
      local memory = Memory:new(0x10000)
      local chip = new_chip(subject, memory)
      chip:set_state(isa.CPU_STATE_RUN)
      chip:set_register_sr(0)
      chip:set_register_pc(0x02FD)
      write_bytes(memory, 0x02FD, { 0xD0, 0x02 })
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0301, chip:get_register_pc())

      chip:set_register_pc(0x0300)
      write_bytes(memory, 0x0300, { 0xD0, 0x80 })
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0282, chip:get_register_pc())
      chip:dispose()
    end)

    t2:test("changes only the named flag and treats NOP as inert", function (t3)
      local instructions = {
        { "CLC", 0x18, 0x01, false }, { "SEC", 0x38, 0x01, true },
        { "CLI", 0x58, 0x04, false }, { "SEI", 0x78, 0x04, true },
        { "CLV", 0xB8, 0x40, false }, { "CLD", 0xD8, 0x08, false },
        { "SED", 0xF8, 0x08, true },
      }

      for _, instruction in ipairs(instructions) do
        local initial = instruction[4] and 0xB6 or 0xFF
        local expected
        if instruction[4] then expected = bit.bor(initial, instruction[3])
        else expected = bit.band(initial, bit.bnot(instruction[3])) end
        local chip = new_running_chip(subject, { instruction[2] })
        chip:set_register_sr(initial)
        chip:set_register_a(0x12)
        chip:set_register_x(0x34)
        chip:set_register_y(0x56)
        t3:assert_eq(isa.OK_CODE, chip:step(), instruction[1])
        t3:assert_eq(expected, bit.band(chip:get_register_sr(), 0xFF), instruction[1])
        t3:assert_eq(0x12, bit.band(chip:get_register_a(), 0xFF), instruction[1])
        t3:assert_eq(0x34, bit.band(chip:get_register_x(), 0xFF), instruction[1])
        t3:assert_eq(0x56, bit.band(chip:get_register_y(), 0xFF), instruction[1])
        chip:dispose()
      end

      local chip = new_running_chip(subject, { 0xEA })
      chip:set_register_sr(0xDB)
      chip:set_register_a(0x12)
      chip:set_register_x(0x34)
      chip:set_register_y(0x56)
      t3:assert_eq(isa.OK_CODE, chip:step(), "NOP")
      t3:assert_eq(0x0201, chip:get_register_pc(), "NOP")
      t3:assert_eq(0xDB, bit.band(chip:get_register_sr(), 0xFF), "NOP")
      t3:assert_eq(0x12, bit.band(chip:get_register_a(), 0xFF), "NOP")
      t3:assert_eq(0x34, bit.band(chip:get_register_x(), 0xFF), "NOP")
      t3:assert_eq(0x56, bit.band(chip:get_register_y(), 0xFF), "NOP")
      chip:dispose()
    end)

    t2:test("sets N and Z correctly for immediate loads", function (t3)
      local opcodes = { 0xA9, 0xA2, 0xA0 } -- LDA, LDX, LDY
      local values = {
        { 0x00, 0x02 },
        { 0x7F, 0x00 },
        { 0x80, 0x80 },
        { 0xFF, 0x80 },
      }

      for _, opcode in ipairs(opcodes) do
        for _, vector in ipairs(values) do
          local chip = new_running_chip(subject, { opcode, vector[1] })
          chip:set_register_sr(0x7D) -- all modeled non-N/Z bits set
          t3:assert_eq(isa.OK_CODE, chip:step())
          t3:assert_eq(vector[2], bit.band(chip:get_register_sr(), 0x82))
          t3:assert_eq(0x7D, bit.band(chip:get_register_sr(), 0x7D))
          chip:dispose()
        end
      end
    end)

    t2:test("executes every LDX and LDY memory encoding", function (t3)
      local vectors = {
        { "LDX zpg",   { 0xA6, 0x40 },       "x", 0x0040 },
        { "LDX zpg,Y", { 0xB6, 0xF0 },       "x", 0x0010, y = 0x20 },
        { "LDX abs",   { 0xAE, 0x34, 0x12 }, "x", 0x1234 },
        { "LDX abs,Y", { 0xBE, 0xF0, 0x12 }, "x", 0x1310, y = 0x20 },
        { "LDY zpg",   { 0xA4, 0x40 },       "y", 0x0040 },
        { "LDY zpg,X", { 0xB4, 0xF0 },       "y", 0x0010, x = 0x20 },
        { "LDY abs",   { 0xAC, 0x34, 0x12 }, "y", 0x1234 },
        { "LDY abs,X", { 0xBC, 0xF0, 0x12 }, "y", 0x1310, x = 0x20 },
      }

      for _, vector in ipairs(vectors) do
        local chip, memory = new_running_chip(subject, vector[2])
        if vector.x then chip:set_register_x(vector.x) end
        if vector.y then chip:set_register_y(vector.y) end
        memory:w_u8(vector[4], 0x80)
        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        local actual = vector[3] == "x" and chip:get_register_x() or chip:get_register_y()
        t3:assert_eq(0x80, bit.band(actual, 0xFF), vector[1])
        t3:assert_eq(0x80, bit.band(chip:get_register_sr(), 0x82), vector[1])
        chip:dispose()
      end
    end)

    t2:test("executes every STX and STY encoding without changing flags", function (t3)
      local vectors = {
        { "STX zpg",   { 0x86, 0x40 },       "x", 0x0040 },
        { "STX zpg,Y", { 0x96, 0xF0 },       "x", 0x0010, y = 0x20 },
        { "STX abs",   { 0x8E, 0x34, 0x12 }, "x", 0x1234 },
        { "STY zpg",   { 0x84, 0x40 },       "y", 0x0040 },
        { "STY zpg,X", { 0x94, 0xF0 },       "y", 0x0010, x = 0x20 },
        { "STY abs",   { 0x8C, 0x34, 0x12 }, "y", 0x1234 },
      }

      for _, vector in ipairs(vectors) do
        local chip, memory = new_running_chip(subject, vector[2])
        chip:set_register_sr(0xA5)
        chip:set_register_x(vector.x or (vector[3] == "x" and 0x5A or 0))
        chip:set_register_y(vector.y or (vector[3] == "y" and 0x5A or 0))
        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        t3:assert_eq(0x5A, memory:r_u8(vector[4]), vector[1])
        t3:assert_eq(0xA5, bit.band(chip:get_register_sr(), 0xFF), vector[1])
        chip:dispose()
      end
    end)

    t2:test("transfers registers and preserves flags for TXS", function (t3)
      local vectors = {
        { "TAX", 0xAA, "a", "x", true },
        { "TAY", 0xA8, "a", "y", true },
        { "TSX", 0xBA, "sp", "x", true },
        { "TXA", 0x8A, "x", "a", true },
        { "TXS", 0x9A, "x", "sp", false },
        { "TYA", 0x98, "y", "a", true },
      }
      local setters = { a = "set_register_a", x = "set_register_x", y = "set_register_y", sp = "set_register_sp" }
      local getters = { a = "get_register_a", x = "get_register_x", y = "get_register_y", sp = "get_register_sp" }

      for _, vector in ipairs(vectors) do
        local chip = new_running_chip(subject, { vector[2] })
        chip:set_register_sr(0x7F)
        chip[setters[vector[3]]](chip, 0x80)
        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        t3:assert_eq(0x80, bit.band(chip[getters[vector[4]]](chip), 0xFF), vector[1])
        local expected = vector[5] and 0xFD or 0x7F
        t3:assert_eq(expected, bit.band(chip:get_register_sr(), 0xFF), vector[1])
        chip:dispose()
      end
    end)

    t2:test("round trips the accumulator through a wrapping stack", function (t3)
      local chip, memory = new_running_chip(subject, { 0x48, 0x68 }) -- PHA; PLA
      chip:set_register_sp(0x00)
      chip:set_register_a(0x80)
      chip:set_register_sr(0x7D)

      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0xFF, chip:get_register_sp())
      t3:assert_eq(0x80, memory:r_u8(0x0100))

      chip:set_register_a(0x00)
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x00, chip:get_register_sp())
      t3:assert_eq(0x80, bit.band(chip:get_register_a(), 0xFF))
      t3:assert_eq(0xFD, bit.band(chip:get_register_sr(), 0xFF))
      chip:dispose()
    end)

    t2:test("synthesizes and ignores status-only stack bits", function (t3)
      local chip, memory = new_running_chip(subject, { 0x08, 0x28 }) -- PHP; PLP
      chip:set_register_sp(0xFF)
      chip:set_register_sr(0x85)

      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0xFE, chip:get_register_sp())
      t3:assert_eq(0xB5, memory:r_u8(0x01FF))

      memory:w_u8(0x01FF, 0xFF)
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0xFF, chip:get_register_sp())
      t3:assert_eq(0xCF, bit.band(chip:get_register_sr(), 0xFF))
      chip:dispose()
    end)

    t2:test("calls and returns with the exact stacked return address", function (t3)
      local chip, memory = new_running_chip(subject, { 0x20, 0x00, 0x03 }) -- JSR $0300
      memory:w_u8(0x0300, 0x60) -- RTS
      chip:set_register_sp(0xFF)

      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0300, chip:get_register_pc())
      t3:assert_eq(0xFD, chip:get_register_sp())
      t3:assert_eq(0x02, memory:r_u8(0x01FF)) -- return address high
      t3:assert_eq(0x02, memory:r_u8(0x01FE)) -- return address low

      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0203, chip:get_register_pc())
      t3:assert_eq(0xFF, chip:get_register_sp())
      chip:dispose()
    end)

    t2:test("wraps both bytes of a subroutine return through page one", function (t3)
      local chip, memory = new_running_chip(subject, { 0x20, 0x00, 0x03 })
      memory:w_u8(0x0300, 0x60)
      chip:set_register_sp(0x00)

      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0xFE, chip:get_register_sp())
      t3:assert_eq(0x02, memory:r_u8(0x0100))
      t3:assert_eq(0x02, memory:r_u8(0x01FF))
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0203, chip:get_register_pc())
      t3:assert_eq(0x00, chip:get_register_sp())
      chip:dispose()
    end)

    t2:test("unwinds nested subroutine calls", function (t3)
      local chip, memory = new_running_chip(subject, { 0x20, 0x00, 0x03 })
      write_bytes(memory, 0x0300, { 0x20, 0x00, 0x04, 0x60 })
      memory:w_u8(0x0400, 0x60)

      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0300, chip:get_register_pc())
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0400, chip:get_register_pc())
      t3:assert_eq(0xFB, chip:get_register_sp())
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0303, chip:get_register_pc())
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0203, chip:get_register_pc())
      t3:assert_eq(0xFF, chip:get_register_sp())
      chip:dispose()
    end)

    t2:test("round trips BRK through RTI", function (t3)
      local chip, memory = new_running_chip(subject, { 0x00, 0xEA })
      memory:w_u8(isa.BREAK_VECTOR_PTR, 0x00)
      memory:w_u8(isa.BREAK_VECTOR_PTR + 1, 0x04)
      memory:w_u8(0x0400, 0x40) -- RTI
      chip:set_register_sr(0x81)

      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0400, chip:get_register_pc())
      t3:assert_eq(0xFC, chip:get_register_sp())
      t3:assert_eq(0x02, memory:r_u8(0x01FF))
      t3:assert_eq(0x02, memory:r_u8(0x01FE))
      t3:assert_eq(0xB1, memory:r_u8(0x01FD))
      t3:assert_eq(0x85, bit.band(chip:get_register_sr(), 0xFF))

      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x0202, chip:get_register_pc())
      t3:assert_eq(0xFF, chip:get_register_sp())
      t3:assert_eq(0x81, bit.band(chip:get_register_sr(), 0xFF))
      chip:dispose()
    end)

    t2:test("executes boolean operations and sets only N and Z", function (t3)
      local vectors = {
        { "AND", 0x29, 0xF0, 0x0F, 0x00, 0x02 },
        { "EOR", 0x49, 0xAA, 0x55, 0xFF, 0x80 },
        { "ORA", 0x09, 0x40, 0x40, 0x40, 0x00 },
      }
      for _, vector in ipairs(vectors) do
        local chip = new_running_chip(subject, { vector[2], vector[4] })
        chip:set_register_a(vector[3])
        chip:set_register_sr(0x7D)
        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        t3:assert_eq(vector[5], bit.band(chip:get_register_a(), 0xFF), vector[1])
        t3:assert_eq(vector[6], bit.band(chip:get_register_sr(), 0x82), vector[1])
        t3:assert_eq(0x7D, bit.band(chip:get_register_sr(), 0x7D), vector[1])
        chip:dispose()
      end
    end)

    t2:test("derives BIT flags from memory without changing A", function (t3)
      for _, bytes in ipairs({ { 0x24, 0x40 }, { 0x2C, 0x34, 0x12 } }) do
        local chip, memory = new_running_chip(subject, bytes)
        local address = bytes[1] == 0x24 and 0x0040 or 0x1234
        memory:w_u8(address, 0xC0)
        chip:set_register_a(0x40)
        chip:set_register_sr(0x3D)
        t3:assert_eq(isa.OK_CODE, chip:step())
        t3:assert_eq(0x40, bit.band(chip:get_register_a(), 0xFF))
        t3:assert_eq(0xC0, bit.band(chip:get_register_sr(), 0xC2))
        t3:assert_eq(0x3D, bit.band(chip:get_register_sr(), 0x3D))
        chip:dispose()
      end

      local chip, memory = new_running_chip(subject, { 0x24, 0x40 })
      memory:w_u8(0x40, 0xC0)
      chip:set_register_a(0x00)
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0xC2, bit.band(chip:get_register_sr(), 0xC2))
      chip:dispose()
    end)

    t2:test("compares A, X, and Y as unsigned bytes", function (t3)
      local opcodes = { { 0xC9, "a" }, { 0xE0, "x" }, { 0xC0, "y" } }
      local vectors = {
        { 0x10, 0x20, 0x80 }, -- less: N
        { 0x80, 0x80, 0x03 }, -- equal: C and Z
        { 0xFF, 0x01, 0x81 }, -- greater: C, with bit 7 set in wrapped result
        { 0x00, 0xFF, 0x00 }, -- unsigned less with positive wrapped result
      }
      local setters = { a = "set_register_a", x = "set_register_x", y = "set_register_y" }
      for _, instruction in ipairs(opcodes) do
        for _, vector in ipairs(vectors) do
          local chip = new_running_chip(subject, { instruction[1], vector[2] })
          chip[setters[instruction[2]]](chip, vector[1])
          chip:set_register_sr(0x7C)
          t3:assert_eq(isa.OK_CODE, chip:step())
          t3:assert_eq(vector[3], bit.band(chip:get_register_sr(), 0x83))
          t3:assert_eq(0x7C, bit.band(chip:get_register_sr(), 0x7C))
          chip:dispose()
        end
      end
    end)

    t2:test("wraps register increments and decrements", function (t3)
      local vectors = {
        { "INX", 0xE8, "x", 0xFF, 0x00, 0x02 },
        { "INY", 0xC8, "y", 0xFF, 0x00, 0x02 },
        { "DEX", 0xCA, "x", 0x00, 0xFF, 0x80 },
        { "DEY", 0x88, "y", 0x00, 0xFF, 0x80 },
      }
      local setters = { x = "set_register_x", y = "set_register_y" }
      local getters = { x = "get_register_x", y = "get_register_y" }
      for _, vector in ipairs(vectors) do
        local chip = new_running_chip(subject, { vector[2] })
        chip[setters[vector[3]]](chip, vector[4])
        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        t3:assert_eq(vector[5], bit.band(chip[getters[vector[3]]](chip), 0xFF), vector[1])
        t3:assert_eq(vector[6], bit.band(chip:get_register_sr(), 0x82), vector[1])
        chip:dispose()
      end
    end)

    t2:test("executes every INC and DEC encoding", function (t3)
      local vectors = {
        { "INC zpg",   { 0xE6, 0x40 },       0x0040, 0xFF, 0x00, 0x02 },
        { "INC zpg,X", { 0xF6, 0xF0 },       0x0010, 0xFF, 0x00, 0x02, x = 0x20 },
        { "INC abs",   { 0xEE, 0x34, 0x12 }, 0x1234, 0xFF, 0x00, 0x02 },
        { "INC abs,X", { 0xFE, 0xF0, 0x12 }, 0x1310, 0xFF, 0x00, 0x02, x = 0x20 },
        { "DEC zpg",   { 0xC6, 0x40 },       0x0040, 0x00, 0xFF, 0x80 },
        { "DEC zpg,X", { 0xD6, 0xF0 },       0x0010, 0x00, 0xFF, 0x80, x = 0x20 },
        { "DEC abs",   { 0xCE, 0x34, 0x12 }, 0x1234, 0x00, 0xFF, 0x80 },
        { "DEC abs,X", { 0xDE, 0xF0, 0x12 }, 0x1310, 0x00, 0xFF, 0x80, x = 0x20 },
      }
      for _, vector in ipairs(vectors) do
        local chip, memory = new_running_chip(subject, vector[2])
        if vector.x then chip:set_register_x(vector.x) end
        memory:w_u8(vector[3], vector[4])
        t3:assert_eq(isa.OK_CODE, chip:step(), vector[1])
        t3:assert_eq(vector[5], memory:r_u8(vector[3]), vector[1])
        t3:assert_eq(vector[6], bit.band(chip:get_register_sr(), 0x82), vector[1])
        chip:dispose()
      end
    end)

    t2:test("executes every shift and rotate encoding", function (t3)
      local families = {
        {
          name = "ASL", input = 0x80, carry_in = 0, output = 0x00, flags = 0x03,
          forms = { { 0x0A }, { 0x06, 0x40 }, { 0x16, 0xF0 },
                    { 0x0E, 0x34, 0x12 }, { 0x1E, 0xF0, 0x12 } },
        },
        {
          name = "LSR", input = 0x01, carry_in = 0, output = 0x00, flags = 0x03,
          forms = { { 0x4A }, { 0x46, 0x40 }, { 0x56, 0xF0 },
                    { 0x4E, 0x34, 0x12 }, { 0x5E, 0xF0, 0x12 } },
        },
        {
          name = "ROL", input = 0x80, carry_in = 1, output = 0x01, flags = 0x01,
          forms = { { 0x2A }, { 0x26, 0x40 }, { 0x36, 0xF0 },
                    { 0x2E, 0x34, 0x12 }, { 0x3E, 0xF0, 0x12 } },
        },
        {
          name = "ROR", input = 0x01, carry_in = 1, output = 0x80, flags = 0x81,
          forms = { { 0x6A }, { 0x66, 0x40 }, { 0x76, 0xF0 },
                    { 0x6E, 0x34, 0x12 }, { 0x7E, 0xF0, 0x12 } },
        },
      }

      for _, family in ipairs(families) do
        for index, bytes in ipairs(family.forms) do
          local label = family.name .. " form " .. index
          local chip, memory = new_running_chip(subject, bytes)
          chip:set_register_sr(0x7C + family.carry_in)
          local accumulator = index == 1
          local target
          if accumulator then
            chip:set_register_a(family.input)
          else
            if index == 2 then target = 0x0040
            elseif index == 3 then target = 0x0010; chip:set_register_x(0x20)
            elseif index == 4 then target = 0x1234
            else target = 0x1310; chip:set_register_x(0x20) end
            memory:w_u8(target, family.input)
          end

          t3:assert_eq(isa.OK_CODE, chip:step(), label)
          local result = accumulator and bit.band(chip:get_register_a(), 0xFF) or memory:r_u8(target)
          t3:assert_eq(family.output, result, label)
          t3:assert_eq(0x7C + family.flags, bit.band(chip:get_register_sr(), 0xFF), label)
          chip:dispose()
        end
      end
    end)

    t2:test("logically rotates an accumulator whose high bit is set", function (t3)
      local chip = new_running_chip(subject, { 0x6A })
      chip:set_register_a(0x82)
      chip:set_register_sr(0x00)
      t3:assert_eq(isa.OK_CODE, chip:step())
      t3:assert_eq(0x41, bit.band(chip:get_register_a(), 0xFF))
      t3:assert_eq(0x00, bit.band(chip:get_register_sr(), 0xC3))
      chip:dispose()
    end)

    t2:test("addresses every ADC and SBC operand mode", function (t3)
      local families = {
        { name = "ADC", opcodes = { 0x69, 0x65, 0x75, 0x6D, 0x7D, 0x79, 0x61, 0x71 } },
        { name = "SBC", opcodes = { 0xE9, 0xE5, 0xF5, 0xED, 0xFD, 0xF9, 0xE1, 0xF1 } },
      }
      local forms = {
        { name = "immediate", bytes = { 0x42 } },
        { name = "zero page", bytes = { 0x80 }, target = 0x0080 },
        { name = "zero page,X wrap", bytes = { 0xF0 }, target = 0x0010, x = 0x20 },
        { name = "absolute", bytes = { 0x34, 0x12 }, target = 0x1234 },
        { name = "absolute,X crossing", bytes = { 0xF0, 0x12 }, target = 0x1310, x = 0x20 },
        { name = "absolute,Y crossing", bytes = { 0xF0, 0x12 }, target = 0x1310, y = 0x20 },
        { name = "(zero page,X) wrap", bytes = { 0xF8 }, target = 0x3456, x = 0x08,
          pointer = { 0x00, 0x56, 0x34 } },
        { name = "(zero page),Y wrap", bytes = { 0xFF }, target = 0x1310, y = 0x20,
          pointer = { 0xFF, 0xF0, 0x12 } },
      }

      for _, family in ipairs(families) do
        for index, form in ipairs(forms) do
          local bytes = { family.opcodes[index] }
          for _, value in ipairs(form.bytes) do bytes[#bytes + 1] = value end
          local chip, memory = new_running_chip(subject, bytes)
          chip:set_register_a(0x10)
          chip:set_register_sr(0x35)
          if form.x then chip:set_register_x(form.x) end
          if form.y then chip:set_register_y(form.y) end
          if form.pointer then
            local address, lo, hi = unpack(form.pointer)
            memory:w_u8(address, lo)
            memory:w_u8((address + 1) % 0x100, hi)
          end
          if form.target then memory:w_u8(form.target, 0x42) end

          local label = family.name .. " " .. form.name
          t3:assert_eq(isa.OK_CODE, chip:step(), label)
          t3:assert_eq(family.name == "ADC" and 0x53 or 0xCE,
                       bit.band(chip:get_register_a(), 0xFF), label)
          chip:dispose()
        end
      end
    end)

    t2:test("exhaustively implements binary ADC and SBC", function (t3)
      local operations = {
        {
          name = "ADC", opcode = 0x69,
          oracle = function (a, operand, carry)
            local wide = a + operand + carry
            local result = wide % 0x100
            local overflow = bit.band(bit.band(bit.bxor(a, result),
                                               bit.bnot(bit.bxor(a, operand))), 0x80) ~= 0
            return result, wide > 0xFF, overflow
          end,
        },
        {
          name = "SBC", opcode = 0xE9,
          oracle = function (a, operand, carry)
            local wide = a - operand - (1 - carry)
            local result = wide % 0x100
            local overflow = bit.band(bit.band(bit.bxor(a, operand),
                                               bit.bxor(a, result)), 0x80) ~= 0
            return result, wide >= 0, overflow
          end,
        },
      }

      for _, operation in ipairs(operations) do
        local chip, memory = new_running_chip(subject, { operation.opcode, 0x00 })
        local mismatch
        for a = 0, 0xFF do
          for operand = 0, 0xFF do
            memory:w_u8(0x0201, operand)
            for carry = 0, 1 do
              chip:set_state(isa.CPU_STATE_RUN)
              chip:set_register_pc(0x0200)
              chip:set_register_a(a)
              chip:set_register_sr(0x34 + carry)

              local status = chip:step()
              local expected, expected_c, expected_v = operation.oracle(a, operand, carry)
              local expected_flags = 0x34
              if expected_c then expected_flags = expected_flags + 0x01 end
              if expected == 0 then expected_flags = expected_flags + 0x02 end
              if expected_v then expected_flags = expected_flags + 0x40 end
              if expected >= 0x80 then expected_flags = expected_flags + 0x80 end

              local actual = bit.band(chip:get_register_a(), 0xFF)
              local actual_flags = bit.band(chip:get_register_sr(), 0xF7)
              if status ~= isa.OK_CODE or actual ~= expected or actual_flags ~= expected_flags then
                mismatch = {
                  operation = operation.name, a = a, operand = operand, carry = carry,
                  status = status, expected = expected, actual = actual,
                  expected_flags = expected_flags, actual_flags = actual_flags,
                }
                break
              end
            end
            if mismatch then break end
          end
          if mismatch then break end
        end
        chip:dispose()
        t3:assert_eq(nil, mismatch)
      end
    end)

    t2:test("exhaustively implements NMOS decimal ADC and SBC", function (t3)
      -- Prediction algorithm derived from Bruce Clark's public-domain
      -- decimal-mode test. This intentionally includes invalid BCD digits.
      local operations = {
        {
          name = "ADC", opcode = 0x69,
          oracle = function (a, operand, carry)
            local binary = a + operand + carry
            local low = bit.band(a, 0x0F) + bit.band(operand, 0x0F) + carry
            if low >= 0x0A then low = low + 0x06 end
            local high = bit.band(a, 0xF0) + bit.band(operand, 0xF0) +
                         bit.band(low, 0xF0)
            local negative = bit.band(high, 0x80) ~= 0
            local overflow = bit.band(bit.band(bit.bxor(a, high),
                                               bit.bnot(bit.bxor(a, operand))), 0x80) ~= 0
            if high >= 0xA0 then high = high + 0x60 end
            local result = bit.band(bit.bor(bit.band(low, 0x0F), high), 0xFF)
            return result, high > 0xFF, overflow,
                   bit.band(binary, 0xFF) == 0, negative
          end,
        },
        {
          name = "SBC", opcode = 0xE9,
          oracle = function (a, operand, carry)
            local binary = a - operand - (1 - carry)
            local binary_result = binary % 0x100
            local low = bit.band(a, 0x0F) - bit.band(operand, 0x0F) - (1 - carry)
            local low_borrow = low < 0
            if low_borrow then low = low - 0x06 end
            local high = bit.band(a, 0xF0) - bit.band(operand, 0xF0) -
                         (low_borrow and 0x10 or 0)
            if high < 0 then high = high - 0x60 end
            local result = bit.band(bit.bor(bit.band(low, 0x0F),
                                            bit.band(high, 0xF0)), 0xFF)
            local overflow = bit.band(bit.band(bit.bxor(a, operand),
                                               bit.bxor(a, binary_result)), 0x80) ~= 0
            return result, binary >= 0, overflow,
                   binary_result == 0, binary_result >= 0x80
          end,
        },
      }

      for _, operation in ipairs(operations) do
        local chip, memory = new_running_chip(subject, { operation.opcode, 0x00 })
        local mismatch
        for a = 0, 0xFF do
          for operand = 0, 0xFF do
            memory:w_u8(0x0201, operand)
            for carry = 0, 1 do
              chip:set_state(isa.CPU_STATE_RUN)
              chip:set_register_pc(0x0200)
              chip:set_register_a(a)
              chip:set_register_sr(0x3C + carry)

              local status = chip:step()
              local expected, expected_c, expected_v, expected_z, expected_n =
                operation.oracle(a, operand, carry)
              local expected_flags = 0x3C
              if expected_c then expected_flags = expected_flags + 0x01 end
              if expected_z then expected_flags = expected_flags + 0x02 end
              if expected_v then expected_flags = expected_flags + 0x40 end
              if expected_n then expected_flags = expected_flags + 0x80 end

              local actual = bit.band(chip:get_register_a(), 0xFF)
              local actual_flags = bit.band(chip:get_register_sr(), 0xFF)
              if status ~= isa.OK_CODE or actual ~= expected or actual_flags ~= expected_flags then
                mismatch = {
                  operation = operation.name, a = a, operand = operand, carry = carry,
                  status = status, expected = expected, actual = actual,
                  expected_flags = expected_flags, actual_flags = actual_flags,
                }
                break
              end
            end
            if mismatch then break end
          end
          if mismatch then break end
        end
        chip:dispose()
        t3:assert_eq(nil, mismatch)
      end
    end)
  end)

  if functional_test_blob and run_full_functional_test and
     (not functional_test_backend or functional_test_backend == subject._name) then
    case:describe("#step with 6502 test", function (t2)
      t2:test("completes the Klaus Dormann functional test", function (t3)
        local memory = Memory:new(0x10000)
        memory:w_blob(0, functional_test_blob)
        local chip = new_chip(subject, memory)

        run_startup(t3, chip)
        -- This image was assembled for a monitor-style harness: its reset
        -- vector is a deliberate failure trap and the documented entry is $0400.
        chip:set_register_pc(0x0400)
        local success_pc = 0x3469
        local instruction_limit = 100000000
        local failure
        local instructions = 0

        while chip:get_register_pc() ~= success_pc and instructions < instruction_limit do
          local pc = chip:get_register_pc()
          local status = chip:step()
          instructions = instructions + 1
          local next_pc = chip:get_register_pc()
          if status ~= isa.OK_CODE then
            failure = { reason = "emulator status", status = status, pc = pc,
                        next_pc = next_pc, instructions = instructions }
            break
          elseif next_pc == pc then
            failure = { reason = "Klaus failure trap", pc = pc,
                        instructions = instructions,
                        a = bit.band(chip:get_register_a(), 0xFF),
                        x = bit.band(chip:get_register_x(), 0xFF),
                        y = bit.band(chip:get_register_y(), 0xFF),
                        sp = bit.band(chip:get_register_sp(), 0xFF),
                        sr = bit.band(chip:get_register_sr(), 0xFF),
                        stack_fc = memory:r_u8(0x01FC),
                        stack_fd = memory:r_u8(0x01FD),
                        stack_fe = memory:r_u8(0x01FE),
                        stack_ff = memory:r_u8(0x01FF) }
            break
          end
        end

        if not failure and chip:get_register_pc() ~= success_pc then
          failure = { reason = "instruction limit", pc = chip:get_register_pc(),
                      instructions = instructions, limit = instruction_limit }
        end
        t3:assert_eq(nil, failure)
        t3:assert_eq(success_pc, chip:get_register_pc())
        chip:dispose()
      end)
    end)
  end

  case:execute()
  case:display_stats()
  case:maybe_error()
end
