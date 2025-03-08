--[[

  OKU FORTH base implementation, see OKU FORTH 8/16/32 for different cell sizes.

]]
local StringBuffer = assert(foundation.com.StringBuffer)
local List = assert(foundation.com.List)

--- @namespace yatm_oku.OKU.isa._OKU_FORTH
yatm_oku.OKU.isa._OKU_FORTH = {}

local ISA = yatm_oku.OKU.isa._OKU_FORTH

--- @class Compiler
ISA.Compiler = foundation.com.Class:extends("yatm_oku.OKU.isa._OKU_FORTH.Compiler")
do
  local ic = assert(ISA.Compiler.instance_class)

  --- @spec #initialize(word_size): void
  function ic:initialize(word_size)
    ic._super.initialize(self)
    self.m_word_size = word_size
  end

  --- @spec #eval(prog: String): Any
  function ic:eval(oku, blob)
    local buf = StringBuffer:new(str, 'r')

    local is_num, word_or_number
    is_num, word_or_number = self:scan_term(buf)
    if is_num then
      oku:call_arch("stack_push", word_or_number)
    else
      oku:call_arch("resolve_word", word_or_number)
    end
  end

  --- @spec #scan_word(buf: StringBuffer): String
  function ic:scan_word(buf)
    -- Skip whitespace
    buf:skip(" ")
    return buf:scan_upto(" ")
  end

  --- @spec #scan_term(buf: StringBuffer): Number | String
  function ic:scan_term(buf)
    local word = self:scan_word(buf)
    local num = tonumber(word)
    return num ~= nil, num or word
  end
end

--- Creates a new implementation of the OKU FORTH of specified word size.
---
--- @spec #make(word_size: Integer, Table): Table
function ISA:make(word_size, isa_def)
  assert(isa_def)

  local isa = {}

  assert(isa_def.builtin)

  ---
  --- ISA Interface
  ---

  --- @spec init(OKU, Table): void
  function isa.init(oku, assigns)
    assigns.word_size = word_size
    --- builtin entries
    assigns.builtin = isa_def.builtin
    --- Contains all defined entries, including user functions, variables and constants
    assigns.dict = {}
    --- The execution stack contains either WORDs or NUMBERs.
    --- As its name suggestions these values are popped and interpreted during the step.
    assigns.execution_stack = List:new()
    --- The return stack contains the position in the execution stack to return to
    --- upon early return the execution stack will be truncated to the value popped from this
    assigns.return_stack = List:new()

    --- The stack starts at the maximum memory size, and decrements upon use and increments upon
    --- being popped, it is up to the user to ensure their stack doesn't bleed into their usable
    --- memory, which is the entire range
    assigns.stack_index = oku.memory:size()
  end

  --- @spec dispose(OKU, Table): void
  function isa.dispose(oku, assigns)
  end

  --- @spec reset(OKU, Table): void
  function isa.reset(oku, assigns)
  end

  --- @spec step(OKU, Table): void
  function isa.step(oku, assigns)
    assigns.cycles = 0
    local item
    local ty
    local err
    while not assigns.execution_stack:is_empty() do
      item = assigns.execution_stack:pop()
      ty = type(item)
      if ty == "number" then
        isa.stack_push(oku, assigns, item)
        cycles = cycles + 1
      elseif ty == "string" then
        if isa.resolve_word(oku, assigns, item) then
          cycles = cycles + 1
        else
          err = "? " .. item
          return false, err
        end
      end
    end
    return true, "ok"
  end

  --- @spec binload(OKU, Table): void
  function isa.binload(oku, assigns, stream)
  end

  --- @spec bindump(OKU, Table): void
  function isa.bindump(oku, assigns, stream)
  end

  ---
  --- @spec resolve_word(OKU, Table, String): void
  function isa.resolve_word(oku, assigns, word)
    local entry = assigns.dict[word]

    if not entry then
      entry = assigns.builtin[word]
    end

    if entry then
      if entry.is_function then
        entry.func(oku, assigns)
      elseif entry.is_def then
        isa.add_to_execution_stack(oku, assigns, entry.def)
      elseif entry.is_address then
        isa.stack_push(oku, assigns, entry.address)
      elseif entry.is_value then
        isa.stack_push(oku, assigns, entry.value)
      end
      return true
    end
    return false, "not found"
  end

  function isa.add_to_execution_stack(oku, assigns, definition)
    local i = #definition
    while i > 0 do
      assigns.execution_stack:push(definition[i])
      i = i - 1
    end
  end

  function isa.stack_push(oku, assigns, number)
    assigns.stack_index = assigns.stack_index - assigns.word_size

    if assigns.stack_index >= 0 then
      if assigns.word_size == 1 then
        oku.memory:w_i8(number)
      elseif assigns.word_size == 2 then
        oku.memory:w_i16(number)
      elseif assigns.word_size == 4 then
        oku.memory:w_i32(number)
      end
      return true, "ok"
    else
      return false, "stack exhausted"
    end
  end

  function isa.stack_pop(oku, assigns)
    if assigns.stack_index < oku.memory:size() then
      local value
      if assigns.word_size == 1 then
        value = oku.memory:r_i8(number)
      elseif assigns.word_size == 2 then
        value = oku.memory:r_i16(number)
      elseif assigns.word_size == 4 then
        value = oku.memory:r_i32(number)
      end
      assigns.stack_index = assigns.stack_index + assigns.word_size
      return true, value, "ok"
    else
      return false, nil, "stack empty"
    end
  end

  return isa
end
