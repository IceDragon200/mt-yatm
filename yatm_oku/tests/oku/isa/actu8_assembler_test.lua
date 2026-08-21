local Luna = assert(foundation.com.Luna)
local bit = assert(foundation.com.bit)
local band = assert(bit.band)
local bor = assert(bit.bor)
local bxor = assert(bit.bxor)
local ACTU8 = assert(yatm_oku.OKU.isa.ACTU8)
local Assembler = assert(ACTU8.Assembler)
local Builder = assert(ACTU8.Builder)
local OKU = assert(yatm_oku.OKU)

local FIBONACCI_SOURCE = [[
  const count = 10

  section code
  start:
    ldi count
    sta remaining
    ldi 0
    sta previous
    ldi 1
    sta current

  next_number:
    lda previous
    out sequence

    lda previous
    add current
    sta next

    lda current
    sta previous
    lda next
    sta current

    lda remaining
    sub one
    sta remaining
    jnz next_number
    halt

  section ram
  one:       byte 1
  previous:  byte 0
  current:   byte 0
  next:      byte 0
  remaining: byte 0

  section io
  sequence: byte 0
]]

local case = Luna:new("yatm_oku.OKU.isa.ACTU8.Assembler")

local function load_program(source)
  local binary, context = Assembler.assemble(source)
  local oku = OKU:new({ arch = "actu8" })
  local memory = oku.memory
  local memory_size = memory:size()

  memory:w_blob(0, binary)
  if #context.sections.ram > 0 then
    memory:w_blob(ACTU8.ram_start(memory_size), context.sections.ram)
  end
  if #context.sections.io > 0 then
    memory:w_blob(ACTU8.io_start(memory_size), context.sections.io)
  end
  return oku, context
end

local function run_program(oku, limit, callback)
  local chip = oku.isa_assigns.chip
  local memory = oku.memory
  local steps = 0
  while not chip:is_halted() and chip.flags.fault == 0 do
    local opcode
    if chip.pc >= 0 and chip.pc < memory:size() then
      opcode = memory:r_u8(chip.pc)
    end
    oku:step(1)
    steps = steps + 1
    if callback then
      callback(opcode, oku)
    end
    if steps > limit then
      error("ACTU8 program exceeded its step limit")
    end
  end
  return steps
end

case:describe("#assemble/1", function (t2)
  t2:test("assembles modern literals, expressions, and labels", function (t3)
    local binary = Assembler.assemble([[
      const count = 0b1010 + 0x02
      start:
        ldi count
        jmp start
        halt
    ]])
    t3:assert_eq(Builder.ldi(12) .. Builder.jmp(0) .. Builder.halt(), binary)
  end)

  t2:test("assembles typed RAM and IO sections", function (t3)
    local binary, context = Assembler.assemble([[
      section code
        lda counter
        out console
        halt
      section ram
        origin 0x20
      counter:
        byte 7
      section io
        origin 0x02
      console:
        byte 0
    ]])
    t3:assert_eq(Builder.lda(0x20) .. Builder.out(0x02) .. Builder.halt(), binary)
    t3:assert_eq(7, context.sections.ram:byte(0x21))
    t3:assert_eq(0, context.sections.io:byte(0x03))
  end)

  t2:test("rejects symbols from the wrong address space", function (t3)
    local ok, err = Assembler.assemble_safe([[
      section ram
      value: byte 1
      section code
      jmp value
    ]])
    t3:assert_eq(false, ok)
    t3:assert(tostring(err):find("expects a code address, got ram", 1, true))
  end)

  t2:test("reports undefined symbols with their source line", function (t3)
    local ok, err = Assembler.assemble_safe("jmp nowhere")
    t3:assert_eq(false, ok)
    t3:assert_eq(ACTU8.AssemblyError, err._class)
    t3:assert_eq(1, err.line)
    t3:assert(tostring(err):find("undefined symbol 'nowhere'", 1, true))
  end)

  t2:test("allows code sections larger than one page", function (t3)
    local values = {}
    for i = 1, 257 do
      values[i] = "0"
    end
    local binary = Assembler.assemble("byte " .. table.concat(values, ","))
    t3:assert_eq(257, #binary)
  end)

  t2:test("allows a forward constant in an origin", function (t3)
    local binary = Assembler.assemble([[
      origin code_start
      start: halt
      const code_start = 0x0100
    ]])
    t3:assert_eq(0x101, #binary)
    t3:assert_eq(Builder.halt(), binary:sub(0x101))
  end)

  t2:test("subtracts labels in the same address space", function (t3)
    local binary = Assembler.assemble([[
      first: nop
      second: nop
      ldi second - first
    ]])
    t3:assert_eq(Builder.nop() .. Builder.nop() .. Builder.ldi(1), binary)
  end)

  t2:test("assembles and executes Fibonacci", function (t3)
    local oku, context = load_program(FIBONACCI_SOURCE)
    local memory = oku.memory
    local chip = oku.isa_assigns.chip
    local memory_size = memory:size()
    local ram_start = ACTU8.ram_start(memory_size)
    local io_start = ACTU8.io_start(memory_size)
    local output = {}

    run_program(oku, 256, function (opcode)
      if opcode == 0x71 then
        output[#output + 1] = memory:r_u8(io_start)
      end
    end)

    t3:assert_table_eq({ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34 }, output)
    t3:assert_eq(55, memory:r_u8(ram_start + context.symbols.previous.value))
    t3:assert_eq(89, memory:r_u8(ram_start + context.symbols.current.value))
  end)

  t2:test("faults when popping an empty stack", function (t3)
    local oku = load_program("pop\nhalt")
    local chip = oku.isa_assigns.chip

    oku:step(1)

    t3:assert_eq(1, chip.flags.fault)
    t3:assert_eq(ACTU8.FAULT_STACK_UNDERFLOW, chip.fc)
    t3:assert_eq(255, chip.sp)
  end)

  t2:test("faults on the push after all 255 stack positions are occupied", function (t3)
    local source = { "ldi 0xa5" }
    for index = 1, 256 do
      source[#source + 1] = "push"
    end
    local oku = load_program(table.concat(source, "\n"))
    local chip = oku.isa_assigns.chip

    oku:step(256) -- LDI followed by 255 successful pushes.
    t3:assert_eq(0, chip.flags.fault)
    t3:assert_eq(0, chip.sp)

    oku:step(1) -- The 256th push would move SP below zero.
    t3:assert_eq(1, chip.flags.fault)
    t3:assert_eq(ACTU8.FAULT_STACK_OVERFLOW, chip.fc)
    t3:assert_eq(0, chip.sp)
  end)

  t2:test("round trips values through the stack", function (t3)
    local oku = load_program([[
      ldi 0x12
      push
      ldi 0x34
      push
      pop
      out result0
      pop
      out result1
      halt

      section io
      result0: byte 0
      result1: byte 0
    ]])
    local memory = oku.memory
    local chip = oku.isa_assigns.chip
    local io_start = ACTU8.io_start(memory:size())

    run_program(oku, 16)

    t3:assert_eq(0x34, memory:r_u8(io_start))
    t3:assert_eq(0x12, memory:r_u8(io_start + 1))
    t3:assert_eq(255, chip.sp)
  end)

  t2:test("calls and returns from a subroutine", function (t3)
    local oku = load_program([[
      call add_pair
      out result
      halt

      add_pair:
        lda lhs
        add rhs
        ret

      section ram
      lhs: byte 19
      rhs: byte 23

      section io
      result: byte 0
    ]])
    local memory = oku.memory
    local chip = oku.isa_assigns.chip

    run_program(oku, 16)

    t3:assert_eq(42, memory:r_u8(ACTU8.io_start(memory:size())))
    t3:assert_eq(255, chip.sp)
  end)

  t2:test("unwinds nested recursive calls", function (t3)
    local oku = load_program([[
      ldi 127
      call recurse
      out result
      halt

      recurse:
        sub one
        jz unwind
        call recurse
      unwind:
        ret

      section ram
      one: byte 1
      section io
      result: byte 0xff
    ]])
    local memory = oku.memory
    local chip = oku.isa_assigns.chip

    run_program(oku, 512)

    t3:assert_eq(0, chip.a)
    t3:assert_eq(255, chip.sp)
    t3:assert_eq(0, memory:r_u8(ACTU8.io_start(memory:size())))
  end)

  t2:test("faults when returning with an empty stack", function (t3)
    local oku = load_program("ret")
    local chip = oku.isa_assigns.chip

    oku:step(1)

    t3:assert_eq(1, chip.flags.fault)
    t3:assert_eq(ACTU8.FAULT_STACK_UNDERFLOW, chip.fc)
    t3:assert_eq(255, chip.sp)
    t3:assert_eq(0, chip.pc)
  end)

  t2:test("faults when a call cannot fit its return address", function (t3)
    local oku, context = load_program([[
      call recurse
      halt
    recurse:
      call recurse
      ret
    ]])
    local chip = oku.isa_assigns.chip

    run_program(oku, 256)

    t3:assert_eq(1, chip.flags.fault)
    t3:assert_eq(ACTU8.FAULT_STACK_OVERFLOW, chip.fc)
    t3:assert_eq(1, chip.sp)
    t3:assert_eq(context.symbols.recurse.value, chip.pc)
  end)

  t2:test("segfaults after returning to a forged out-of-bounds address", function (t3)
    local oku = load_program([[
      call corrupt_return_address
      halt

    corrupt_return_address:
      pop           // Discard the real return-address high byte.
      pop           // Discard the real return-address low byte.
      ldi 0xff
      push          // Forged low byte.
      ldi 0xff
      push          // Forged high byte.
      ret
    ]])
    local chip = oku.isa_assigns.chip

    run_program(oku, 16)

    t3:assert_eq(1, chip.flags.fault)
    t3:assert_eq(ACTU8.FAULT_SEGFAULT, chip.fc)
    t3:assert_eq(0xffff, chip.pc)
  end)

  t2:test("rejects execution in IO, RAM, and stack pages", function (t3)
    local targets = { 0x0500, 0x0600, 0x0700 }
    for _, target in ipairs(targets) do
      local oku = load_program("jmp " .. target)
      local chip = oku.isa_assigns.chip

      run_program(oku, 4)

      t3:assert_eq(1, chip.flags.fault)
      t3:assert_eq(ACTU8.FAULT_ACCESS_VIOLATION, chip.fc)
      t3:assert_eq(target, chip.pc)
    end
  end)

  t2:test("clears zero, carry, and borrow flags", function (t3)
    local oku = load_program([[
      ldi 0
      clz
      jz failed
      ldi 255
      add one
      clc
      jc failed
      ldi 0
      sub one
      clb
      jb failed
      ldi 0xa5
      out result
      halt
    failed:
      halt

      section ram
      one: byte 1
      section io
      result: byte 0
    ]])
    local memory = oku.memory
    local chip = oku.isa_assigns.chip

    run_program(oku, 32)

    t3:assert_eq(0, chip.flags.zero)
    t3:assert_eq(0, chip.flags.carry)
    t3:assert_eq(0, chip.flags.borrow)
    t3:assert_eq(0xa5, memory:r_u8(ACTU8.io_start(memory:size())))
  end)

  t2:test("executes bitwise AND, OR, and XOR", function (t3)
    local oku, context = load_program([[
      lda lhs
      and rhs
      out and_result
      lda lhs
      or rhs
      out or_result
      lda lhs
      xor rhs
      out xor_result
      halt

      section ram
      lhs: byte 0
      rhs: byte 0
      section io
      and_result: byte 0
      or_result: byte 0
      xor_result: byte 0
    ]])
    local memory = oku.memory
    local io_start = ACTU8.io_start(memory:size())
    local lhs_address = ACTU8.ram_address(memory:size(), context.symbols.lhs.value)
    local rhs_address = ACTU8.ram_address(memory:size(), context.symbols.rhs.value)

    for iteration = 1, 2048 do
      local lhs = math.random(0, 255)
      local rhs = math.random(0, 255)
      oku:reset()
      memory:w_u8(lhs_address, lhs)
      memory:w_u8(rhs_address, rhs)

      run_program(oku, 16)

      t3:assert_eq(band(lhs, rhs), memory:r_u8(io_start + context.symbols.and_result.value))
      t3:assert_eq(bor(lhs, rhs), memory:r_u8(io_start + context.symbols.or_result.value))
      t3:assert_eq(bxor(lhs, rhs), memory:r_u8(io_start + context.symbols.xor_result.value))
    end
  end)

  t2:test("takes zero, carry, borrow, and interrupt branches", function (t3)
    local oku = load_program([[
      ldi 0
      jnz failed
      jz zero_ok
    failed:
      halt
    zero_ok:
      ldi 255
      add one
      jnc failed
      jc carry_ok
    carry_ok:
      ldi 0
      sub one
      jnb failed
      jb borrow_ok
    borrow_ok:
      cli
      ji failed
      jni success
    success:
      ldi 0xa5
      out result
      halt

      section ram
      one: byte 1
      section io
      result: byte 0
    ]])
    local memory = oku.memory

    run_program(oku, 32)

    t3:assert_eq(0xa5, memory:r_u8(ACTU8.io_start(memory:size())))
  end)

  t2:test("echoes an input byte to a separate output port", function (t3)
    local oku = load_program([[
      in input
      out output
      halt

      section io
      input: byte 0x7b
      output: byte 0
    ]])
    local memory = oku.memory
    local io_start = ACTU8.io_start(memory:size())

    run_program(oku, 8)

    t3:assert_eq(0x7b, memory:r_u8(io_start))
    t3:assert_eq(0x7b, memory:r_u8(io_start + 1))
  end)

  t2:test("computes a greatest common divisor", function (t3)
    local oku = load_program([[
      again:
        lda lhs
        cmp rhs
        jz done
        jb rhs_is_larger
        sub rhs
        sta lhs
        jmp again
      rhs_is_larger:
        lda rhs
        sub lhs
        sta rhs
        jmp again
      done:
        lda lhs
        out result
        halt

      section ram
      lhs: byte 48
      rhs: byte 18
      section io
      result: byte 0
    ]])
    local memory = oku.memory

    run_program(oku, 128)

    t3:assert_eq(6, memory:r_u8(ACTU8.io_start(memory:size())))
  end)

  t2:test("executes code assembled at a nonzero origin", function (t3)
    local oku, context = load_program([[
      origin 0x0100
      start:
        jmp finish
        halt
      finish:
        ldi 0x5a
        out result
        halt

      section io
      result: byte 0
    ]])
    local memory = oku.memory
    local chip = oku.isa_assigns.chip
    chip.pc = context.symbols.start.value

    run_program(oku, 8)

    t3:assert_eq(0x5a, memory:r_u8(ACTU8.io_start(memory:size())))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
