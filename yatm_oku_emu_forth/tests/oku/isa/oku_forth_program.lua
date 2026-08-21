local Luna = assert(foundation.com.Luna)
local OKU = assert(yatm_oku.OKU)
local Forth = assert(yatm_oku.OKU.isa._OKU_FORTH)
local Buffer = assert(foundation.com.BinaryBuffer or foundation.com.StringBuffer)

local ARCHITECTURES = {
  { name = "oku_forth8", word_size = 1, si_min = -0x80, si_max = 0x7F },
  { name = "oku_forth16", word_size = 2, si_min = -0x8000, si_max = 0x7FFF },
  { name = "oku_forth32", word_size = 4, si_min = -0x80000000, si_max = 0x7FFFFFFF },
}

local function new_machine(arch, memory_size, dictionary_size)
  return OKU:new({
    arch = arch.name,
    memory_size = memory_size,
    dictionary_size = dictionary_size,
  })
end

local function run(machine, source)
  machine:call_arch("eval", source)
  local count = machine:call_arch("execution_stack_size")
  return machine:step(count)
end

local function pop_all(machine)
  local result = {}
  while true do
    local ok, value = machine:call_arch("stack_pop")
    if not ok then
      break
    end
    result[#result + 1] = value
  end
  return result
end

local function run_to_completion(machine, limit)
  local steps = 0
  while machine:call_arch("execution_stack_size") > 0 do
    if steps >= limit then
      return steps, Forth.ERR_FATAL
    end
    local _, err = machine:step(1)
    steps = steps + 1
    if err ~= Forth.ERR_OK then
      return steps, err
    end
  end
  return steps, Forth.ERR_OK
end

local cases = {}

for _, arch in ipairs(ARCHITECTURES) do
  local case = Luna:new("yatm_oku.OKU.ISA." .. arch.name .. " integration")
  cases[#cases + 1] = case

  case:describe("program execution", function (t2)
    t2:test("runs a kitchen-sink stack and arithmetic program", function (t3)
      local machine = new_machine(arch)
      local steps, err = run(machine, "10 3 - 6 7 * 20 4 / 20 6 MOD " ..
        "1 2 SWAP OVER 3 4 TUCK 5 6 7 ROT 11 22 2>R 2R> BL")

      t3:assert_eq(Forth.ERR_OK, err)
      t3:assert_eq(28, steps)
      -- stack_pop returns top-to-bottom order.
      t3:assert_table_eq({
        32,
        22, 11,
        5, 7, 6,
        4, 3, 4,
        2, 1, 2,
        2, 5, 42, 7,
      }, pop_all(machine))
    end)

    t2:test("stores, copies, and fetches one cell", function (t3)
      local machine = new_machine(arch)
      local steps, err = run(machine, "42 0 ! 0 WORD_SIZE WORD_SIZE MOVE WORD_SIZE @")

      t3:assert_eq(Forth.ERR_OK, err)
      t3:assert_eq(9, steps)
      t3:assert_table_eq({ 42 }, pop_all(machine))
    end)

    t2:test("writes characters and numbers to stdout", function (t3)
      local machine = new_machine(arch)
      local _, err = run(machine, "65 emit 42 .")
      t3:assert_eq(Forth.ERR_OK, err)

      local ok, output, output_err = machine:call_arch("stdout_pop")
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, output_err)
      t3:assert_eq("A42", output)
    end)

    t2:test("accepts ordinary Forth whitespace", function (t3)
      local machine = new_machine(arch)
      local _, err = run(machine, "1\t2\n+\r\n")
      t3:assert_eq(Forth.ERR_OK, err)
      t3:assert_table_eq({ 3 }, pop_all(machine))
    end)

    t2:test("wraps signed arithmetic to the configured cell width", function (t3)
      local machine = new_machine(arch)
      local _, err = run(machine, tostring(arch.si_max) .. " 1 +")
      t3:assert_eq(Forth.ERR_OK, err)
      t3:assert_table_eq({ arch.si_min }, pop_all(machine))
    end)
  end)

  case:describe("machine boundaries", function (t2)
    t2:test("uses every complete cell in data-stack memory", function (t3)
      local memory_size = arch.word_size * 4
      local machine = new_machine(arch, memory_size)

      for value = 1,4 do
        local ok, err = machine:call_arch("stack_push", value)
        t3:assert(ok)
        t3:assert_eq(Forth.ERR_OK, err)
      end

      local ok, err = machine:call_arch("stack_push", 5)
      t3:refute(ok)
      t3:assert_eq(Forth.ERR_STACK_FULL, err)
    end)

    t2:test("reset clears pending execution and stack state", function (t3)
      local machine = new_machine(arch)
      machine:call_arch("eval", "1 2 3")
      machine:call_arch("stack_push", 4)
      machine:reset()

      t3:assert_eq(0, machine:call_arch("execution_stack_size"))
      local ok, _, err = machine:call_arch("stack_peek")
      t3:refute(ok)
      t3:assert_eq(Forth.ERR_STACK_EMPTY, err)
    end)

    t2:test("reports an unknown word without claiming success", function (t3)
      local machine = new_machine(arch)
      local _, err = run(machine, "THIS-WORD-DOES-NOT-EXIST")
      t3:assert_eq(Forth.ERR_WORD_DOES_NOT_EXIST, err)
    end)
  end)

  case:describe("user dictionary", function (t2)
    t2:test("defines and late-binds composed colon words", function (t3)
      local machine = new_machine(arch)
      local ok, err = machine:call_arch("eval",
        ": SQUARE DUP * ; : SQUARES SQUARE SWAP SQUARE ; " ..
        "3 4 SQUARES : SQUARE DUP * DUP + ; 5 SQUARE")
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, err)

      local steps, step_err = run_to_completion(machine, 100)
      t3:assert_eq(Forth.ERR_OK, step_err)
      t3:assert(steps > 5)
      -- OKU Forth deliberately resolves names when they execute, so redefining
      -- SQUARE also updates the implementation used by SQUARES.
      t3:assert_table_eq({ 50, 18, 32 }, pop_all(machine))
    end)

    t2:test("rejects incomplete definitions without scheduling their body", function (t3)
      local machine = new_machine(arch)
      local ok, err = machine:call_arch("eval", ": BROKEN 1 2 +")
      t3:refute(ok)
      t3:assert_eq(Forth.ERR_COMPILE, err)
      t3:assert_eq(0, machine:call_arch("execution_stack_size"))
    end)

    t2:test("enforces a dictionary budget", function (t3)
      local machine = new_machine(arch, nil, 16)
      local ok, err = machine:call_arch("eval", ": TOO-LARGE 1 2 3 4 ;")
      t3:refute(ok)
      t3:assert_eq(Forth.ERR_DICTIONARY_FULL, err)

      local _, run_err = run(machine, "TOO-LARGE")
      t3:assert_eq(Forth.ERR_WORD_DOES_NOT_EXIST, run_err)
    end)

    t2:test("treats names case-insensitively and ignores comments", function (t3)
      local machine = new_machine(arch)
      local ok, err = machine:call_arch("eval", [[
        ( square a number ) : Square dup * ;
        6 sQuArE \ the remainder of this line is ignored
        7 SQUARE
      ]])
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, err)
      local _, run_err = run_to_completion(machine, 100)
      t3:assert_eq(Forth.ERR_OK, run_err)
      t3:assert_table_eq({ 49, 36 }, pop_all(machine))
    end)

    t2:test("persists executable definitions and quota accounting", function (t3)
      local machine = new_machine(arch)
      local ok, err = machine:call_arch("eval", ": DOUBLE DUP + ;")
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, err)

      local stream = Buffer:new("", "w")
      machine:bindump(stream)
      machine:dispose()

      machine = new_machine(arch)
      stream:reopen("r")
      machine:binload(stream)
      ok, err = machine:call_arch("eval", "21 double")
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, err)
      local _, run_err = run_to_completion(machine, 100)
      t3:assert_eq(Forth.ERR_OK, run_err)
      t3:assert_table_eq({ 42 }, pop_all(machine))

      ok, err = machine:call_arch("eval", ": DOUBLE DUP + DUP + ;")
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, err)
    end)
  end)

  case:describe("cell operations", function (t2)
    t2:test("produces canonical Forth flags for comparisons", function (t3)
      local machine = new_machine(arch)
      local _, err = run(machine,
        "1 1 = 1 2 = 1 2 <> 1 2 < 2 1 > 0 0= -1 0<")
      t3:assert_eq(Forth.ERR_OK, err)
      t3:assert_table_eq({ -1, -1, -1, -1, -1, 0, -1 }, pop_all(machine))
    end)

    t2:test("performs bitwise operations at the architecture cell width", function (t3)
      local machine = new_machine(arch)
      local _, err = run(machine,
        "85 15 AND 85 15 OR 85 15 XOR 0 INVERT " ..
        "1 " .. tostring(arch.word_size * 8 - 1) .. " LSHIFT -1 1 RSHIFT")
      t3:assert_eq(Forth.ERR_OK, err)
      t3:assert_table_eq({ arch.si_max, arch.si_min, -1, 90, 95, 5 }, pop_all(machine))
    end)
  end)

  case:describe("compiled control flow", function (t2)
    t2:test("selects IF and ELSE bodies", function (t3)
      local machine = new_machine(arch)
      local ok, err = machine:call_arch("eval",
        ": ABS2 DUP 0< IF -1 * THEN ; " ..
        ": CHOOSE IF 11 ELSE 22 THEN ; " ..
        "-5 ABS2 7 ABS2 0 CHOOSE -1 CHOOSE")
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, err)
      local _, run_err = run_to_completion(machine, 100)
      t3:assert_eq(Forth.ERR_OK, run_err)
      t3:assert_table_eq({ 11, 22, 7, 5 }, pop_all(machine))
    end)

    t2:test("loops with BEGIN/UNTIL and BEGIN/WHILE/REPEAT", function (t3)
      local machine = new_machine(arch)
      local ok, err = machine:call_arch("eval",
        ": COUNTDOWN BEGIN 1 - DUP 0= UNTIL ; " ..
        ": SUMDOWN 0 SWAP BEGIN DUP WHILE TUCK + SWAP 1 - REPEAT DROP ; " ..
        "3 COUNTDOWN 5 SUMDOWN")
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, err)
      local _, run_err = run_to_completion(machine, 500)
      t3:assert_eq(Forth.ERR_OK, run_err)
      t3:assert_table_eq({ 15, 0 }, pop_all(machine))
    end)

    t2:test("rejects unbalanced control words", function (t3)
      local machine = new_machine(arch)
      for _, source in ipairs({
        ": BAD IF 1 ;",
        ": BAD BEGIN 1 ;",
        ": BAD ELSE ;",
        ": BAD BEGIN 1 WHILE 2 ;",
      }) do
        local ok, err = machine:call_arch("eval", source)
        t3:refute(ok)
        t3:assert_eq(Forth.ERR_COMPILE, err)
      end
    end)
  end)

  case:describe("runtime limits", function (t2)
    t2:test("bounds the execution stack", function (t3)
      local machine = new_machine(arch)
      local words = {}
      for i = 1,4097 do words[i] = "0" end
      local ok, err = machine:call_arch("eval", table.concat(words, " "))
      t3:refute(ok)
      t3:assert_eq(Forth.ERR_EXECUTION_STACK_FULL, err)
      t3:assert_eq(0, machine:call_arch("execution_stack_size"))
    end)

    t2:test("bounds the return stack without losing the rejected value", function (t3)
      local machine = new_machine(arch)
      local words = {}
      for i = 1,257 do
        words[#words + 1] = "1"
        words[#words + 1] = ">R"
      end
      local ok, err = machine:call_arch("eval", table.concat(words, " "))
      t3:assert(ok)
      t3:assert_eq(Forth.ERR_OK, err)
      local _, run_err = run_to_completion(machine, 1024)
      t3:assert_eq(Forth.ERR_RETURN_STACK_FULL, run_err)
      t3:assert_table_eq({ 1 }, pop_all(machine))
    end)
  end)

  case:execute()
  case:display_stats()
end

for _, case in ipairs(cases) do
  case:maybe_error()
end
