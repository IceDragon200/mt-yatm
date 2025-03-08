--[[

  OKU FORTH base implementation, see OKU FORTH 8/16/32 for different cell sizes.

]]
local StringBuffer = assert(foundation.com.StringBuffer)
local List = assert(foundation.com.List)
local table_merge = assert(foundation.com.table_merge)
local ByteBuf = assert(foundation.com.ByteBuf.little)

--
local Marshall = foundation.com.binary_types.MarshallValue:new()

--- @namespace yatm_oku.OKU.isa._OKU_FORTH
yatm_oku.OKU.isa._OKU_FORTH = {}

local ISA = yatm_oku.OKU.isa._OKU_FORTH

--- @const ERR_OK: Integer
ISA.ERR_OK = 0

--- @const ERR_IN_INTERRUPT: Integer
ISA.ERR_IN_INTERRUPT = 1

--- @const ERR_WORD_DOES_NOT_EXIST: Integer
ISA.ERR_WORD_DOES_NOT_EXIST = 4

--- @const ERR_STACK_EMPTY: Integer
ISA.ERR_STACK_EMPTY = 100

--- @const ERR_STACK_FULL: Integer
ISA.ERR_STACK_FULL = 101

--- @const ERR_STDOUT_EMPTY: Integer
ISA.ERR_STDOUT_EMPTY = 110

--- @const ERR_STDOUT_FULL: Integer
ISA.ERR_STDOUT_FULL = 111

--- @const ERR_RETURN_STACK_EMPTY: Integer
ISA.ERR_RETURN_STACK_EMPTY = 120

--- @const ERR_RETURN_STACK_FULL: Integer
ISA.ERR_RETURN_STACK_FULL = 121

--- @const ERR_FATAL: Integer
ISA.ERR_FATAL = 255

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
    local buf = StringBuffer:new(blob, 'r')

    local _is_num, word_or_number
    local result = List:new()
    while not buf:isEOF() do
      _is_num, word_or_number = self:scan_term(buf)
      result:push(word_or_number)
    end

    oku:call_arch("concat_to_execution_stack", result)
    return true, ISA.ERR_OK
  end

  --- @spec #scan_word(buf: StringBuffer): String
  function ic:scan_word(buf)
    -- Skip whitespace
    buf:skip(" ")
    local word = buf:scan_upto(" ")
    if not word then
      word = buf:read()
    end
    return word
  end

  --- @spec #scan_term(buf: StringBuffer): Number | String
  function ic:scan_term(buf)
    local word = self:scan_word(buf)
    local num = tonumber(word)
    return num ~= nil, num or word
  end
end

ISA.forth_builtin = {
  ["."] = {
    --- (u --)
    cycles = 2,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok, value, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        assigns.stdout:write(tostring(value))
        assigns.cycles = assigns.cycles + 1
        return true, ISA.ERR_OK
      else
        return false, err
      end
    end,
  },

  emit = {
    --- (u --)
    cycles = 2,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok, value, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        --- TODO: prevent flooding the STDOUT
        assigns.stdout:write(string.char(value))
        assigns.cycles = assigns.cycles + 1
        return true, ISA.ERR_OK
      else
        return false, err
      end
    end
  },

  [";I"] = {
    --- (--)
    cycles = 1,
    is_function = true,
    func = function (isa, oku, assigns)
      assigns.interrupt = true
      assigns.cycles = assigns.cycles + 1
      return true
    end,
  },

  ["!"] = {
    --- (x a-addr --)
    cycles = 3,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local addr
      local err
      local value
      ok, addr, err = isa.stack_pop(oku, assigns)

      if ok then
        assigns.cycles = assigns.cycles + 1
        ok, value, err = isa.stack_pop(oku, assigns)
        if ok then
          assigns.cycles = assigns.cycles + 1
          ok, err = isa.memory_write(oku, assigns, addr, value)
          if ok then
            assigns.cycles = assigns.cycles + 1
            return true, ISA.ERR_OK
          else
            return false, err
          end
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["@"] = {
    --- (a-addr -- x)
    cycles = 3,
    is_function = true,
    func = function (isa, oku, assigns)
      --- No, we aren't going to check if this address is correctly aligned,
      --- that's the programmer's responsibility.
      local ok, addr, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        local value
        ok, value, err = isa.memory_read(oku, assigns, addr)
        if ok then
          assigns.cycles = assigns.cycles + 1
          ok, err = isa.stack_push(oku, assigns, value)
          if ok then
            assigns.cycles = assigns.cycles + 1
            return true, ISA.ERR_OK
          else
            return false, err
          end
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["+"] = {
    --- (n1 n2 -- n3)
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local n1
      local n2
      local ok
      local err
      ok, n2, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        ok, n1, err = isa.stack_pop(oku, assigns)
        if ok then
          assigns.cycles = assigns.cycles + 1

          local n3 = isa.truncate_number(oku, isa, n1 + n2)
          assigns.cycles = assigns.cycles + 1

          ok, err = isa.stack_push(oku, assigns, n3)
          assigns.cycles = assigns.cycles + 1

          return true, err
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["-"] = {
    --- (n1 n2 -- n3)
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local n1
      local n2
      local ok
      local err
      ok, n2, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        ok, n1, err = isa.stack_pop(oku, assigns)
        if ok then
          assigns.cycles = assigns.cycles + 1

          local n3 = isa.truncate_number(oku, isa, n1 - n2)
          assigns.cycles = assigns.cycles + 1

          ok, err = isa.stack_push(oku, assigns, n3)
          assigns.cycles = assigns.cycles + 1

          return true, err
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["*"] = {
    --- (n1 n2 -- n3)
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local n1
      local n2
      local ok
      local err
      ok, n2, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        ok, n1, err = isa.stack_pop(oku, assigns)
        if ok then
          assigns.cycles = assigns.cycles + 1

          local n3 = isa.truncate_number(oku, isa, n1 * n2)
          assigns.cycles = assigns.cycles + 1

          ok, err = isa.stack_push(oku, assigns, n3)
          assigns.cycles = assigns.cycles + 1

          return true, err
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["/"] = {
    --- (n1 n2 -- n3)
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local n1
      local n2
      local ok
      local err
      ok, n2, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        ok, n1, err = isa.stack_pop(oku, assigns)
        if ok then
          assigns.cycles = assigns.cycles + 1

          if n2 == 0 then
            return false, "division by zero"
          else
            local n3 = isa.truncate_number(oku, isa, n1 / n2)
            assigns.cycles = assigns.cycles + 1

            ok, err = isa.stack_push(oku, assigns, n3)
            assigns.cycles = assigns.cycles + 1

            return true, err
          end
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["MOD"] = {
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local n1
      local n2
      local ok
      local err
      ok, n2, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        ok, n1, err = isa.stack_pop(oku, assigns)
        if ok then
          assigns.cycles = assigns.cycles + 1

          if n2 == 0 then
            return false, "division by zero"
          else
            local n3 = isa.truncate_number(oku, isa, n1 % n2)
            assigns.cycles = assigns.cycles + 1

            ok, err = isa.stack_push(oku, assigns, n3)
            assigns.cycles = assigns.cycles + 1

            return true, err
          end
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["MOVE"] = {
    --- (addr1 addr2 u --)
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local addr1
      local addr2
      local u
      local ok
      local err
      ok, u, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        ok, addr2, err = isa.stack_pop(oku, assigns)
        if ok then
          assigns.cycles = assigns.cycles + 1

          ok, addr1, err = isa.stack_pop(oku, assigns)
          if ok then
            assigns.cycles = assigns.cycles + 1

            isa.memory_copy(oku, assigns, addr1, addr2, u)
            --- NOTE: this... isn't really correct, because if you copy half of the memory,
            --- that would take much longer than copying a single cell...
            assigns.cycles = assigns.cycles + 1
            return true, ISA.ERR_OK
          else
            return false, err
          end
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["CELLS"] = {
    --- (n1 -- n2)
    cycles = 3,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local n1
      local err

      ok, n1, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1

        local n2 = n1 * isa.WORD_SIZE
        assigns.cycles = assigns.cycles + 1

        ok, err = isa.stack_push(oku, assigns, n2)
        if ok then
          assigns.cycles = assigns.cycles + 1

          return true, ISA.ERR_OK
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["DUP"] = {
    --- (x -- x x)
    cycles = 3,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local x
      local err

      ok, x, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1

        ok, err = isa.stack_push(oku, assigns, x)
        if ok then
          assigns.cycles = assigns.cycles + 1
          ok, err = isa.stack_push(oku, assigns, x)
          if ok then
            assigns.cycles = assigns.cycles + 1
            return true, ISA.ERR_OK
          else
            return false, err
          end
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["SWAP"] = {
    --- (x1 x2 -- x2 x1)
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local x1
      local x2
      local err

      ok, x2, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1

        ok, x1, err = isa.stack_pop(oku, assigns)
        if ok then
          assigns.cycles = assigns.cycles + 1

          ok, err = isa.stack_push(oku, assigns, x2)
          if ok then
            assigns.cycles = assigns.cycles + 1

            ok, err = isa.stack_push(oku, assigns, x1)
            if ok then
              assigns.cycles = assigns.cycles + 1
              return true, ISA.ERR_OK
            else
              return false, err
            end
          else
            return false, err
          end
        else
          return false, err
        end
      else
        return false, err
      end
    end,
  },

  ["ROT"] = {
    --- (x1 x2 x3 -- x2 x3 x1)
    cycles = 6,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local x1
      local x2
      local x3
      local err

      ok, x3, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      ok, x2, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      ok, x1, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      ok, err = isa.stack_push(oku, assigns, x2)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      ok, err = isa.stack_push(oku, assigns, x3)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      ok, err = isa.stack_push(oku, assigns, x1)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      return true, ISA.ERR_OK
    end,
  },

  BL = {
    is_value = true,
    value = 20,
  },

  ABS = {
    --- (n -- u)
    cycles = 3,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local n
      local err

      ok, n, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      local u = math.abs(n)
      assigns.cycles = assigns.cycles + 1

      ok, err = isa.stack_push(oku, assigns, u)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      return true, ISA.ERR_OK
    end,
  },

  [">R"] = {
    --- (x --) (R: -- x)
    cycles = 2,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local x
      local err

      ok, x, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      assigns.return_stack:push(x)
      assigns.cycles = assigns.cycles + 1

      return true, ISA.ERR_OK
    end
  },

  ["R>"] = {
    --- (-- x) (R: x --)
    cycles = 2,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local x
      local err

      if assigns.return_stack:is_empty() then
        return false, ISA.ERR_RETURN_STACK_EMPTY
      else
        x = assigns.return_stack:pop()
        assigns.cycles = assigns.cycles + 1

        ok, err = isa.stack_push(oku, assigns, x)
        if ok then
          assigns.cycles = assigns.cycles + 1
          return true, ISA.ERR_OK
        else
          return false, err
        end
      end
    end
  },

  ["2>R"] = {
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local x1
      local x2
      local err

      ok, x2, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      ok, x1, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      assigns.return_stack:push(x1)
      assigns.cycles = assigns.cycles + 1

      assigns.return_stack:push(x2)
      assigns.cycles = assigns.cycles + 1

      return true, ISA.ERR_OK
    end,
  },

  ["2R>"] = {
    --- (-- x1 x2) (R: x1 x2 --)
    cycles = 4,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local x1
      local x2
      local err

      if assigns.return_stack:is_empty() then
        return false, ISA.ERR_RETURN_STACK_EMPTY
      else
        x2 = assigns.return_stack:pop()
        assigns.cycles = assigns.cycles + 1
      end

      if assigns.return_stack:is_empty() then
        return false, ISA.ERR_RETURN_STACK_EMPTY
      else
        x1 = assigns.return_stack:pop()
        assigns.cycles = assigns.cycles + 1
      end

      ok, err = isa.stack_push(oku, assigns, x1)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      ok, err = isa.stack_push(oku, assigns, x2)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      return true, ISA.ERR_OK
    end
  },
}

--- Creates a new implementation of the OKU FORTH of specified word size.
---
--- @spec #make(word_size: Integer, Table): Table
function ISA:make(word_size, isa_def)
  assert(isa_def)

  local bit_count = word_size * 8
  local isa = {
    WORD_SIZE = word_size,
    compiler = ISA.Compiler:new(word_size),
    BIT_COUNT = bit_count,
    UI_MIN = 0,
    UI_MAX = math.pow(2, bit_count)-1,
    SI_MIN = -math.pow(2, bit_count-1),
    SI_MAX = math.pow(2, bit_count-1)-1,
  }

  local builtin = table_merge({
    WORD_SIZE = {
      is_value = true,
      value = word_size,
    },
  }, isa_def.builtin)

  setmetatable(builtin, { __index = ISA.forth_builtin })
  ---
  --- ISA Interface
  ---

  --- @spec init(OKU, Table): void
  function isa.init(oku, assigns)
    --- stdout
    assigns.stdout = StringBuffer:new("", "w")

    --- builtin entries
    assigns.builtin = builtin
    --- Contains all defined entries, including user functions, variables and constants
    assigns.dict = {}
    --- The execution stack contains either WORDs or NUMBERs.
    --- As its name suggests these values are popped and interpreted during the step.
    assigns.execution_stack = List:new()
    --- The return stack contains the position in the execution stack to return to
    --- upon early return the execution stack will be truncated to the value popped from this
    assigns.return_stack = List:new()

    --- The stack starts at the maximum memory size, and decrements upon use and increments upon
    --- being popped, it is up to the user to ensure their stack doesn't bleed into their usable
    --- memory, which is the entire range
    --- The stack is zero indexed.
    assigns.stack_index = oku.memory:size() - 1
  end

  --- @spec dispose(OKU, Table): void
  function isa.dispose(oku, assigns)
    --
  end

  --- @spec reset(OKU, Table): void
  function isa.reset(oku, assigns)
    --
  end

  function isa.eval(oku, assigns, blob)
    isa.compiler:eval(oku, blob)
  end

  --- @spec step(OKU, Table): void
  function isa.step(oku, assigns)
    if assigns.interrupt then
      return false, ISA.ERR_IN_INTERRUPT
    else
      assigns.cycles = 0

      local item
      local ty
      local err
      local ok
      if not assigns.execution_stack:is_empty() then
        item = assigns.execution_stack:pop()
        print("STEP " .. item)
        ty = type(item)
        if ty == "number" then
          isa.stack_push(oku, assigns, item)
          assigns.cycles = assigns.cycles + 1
        elseif ty == "string" then
          ok, err = isa.execute_word(oku, assigns, item)
          if ok then
            --
          else
            return false, err
          end
        end
      end
      return true, ISA.ERR_OK
    end
  end

  --- @spec binload(OKU, Table): void
  function isa.binload(oku, assigns, stream)
    local bytes_read = 0
    local br
    local version
    version, br = ByteBuf:r_u32(stream)
    if version == 1 then
      local stdout
      local dict
      local execution_stack_size
      local execution_stack
      local return_stack_size
      local return_stack
      local stack_index

      stdout, br = Marshall:read(stream)
      bytes_read = bytes_read + br

      dict, br = Marshall:read(stream)
      bytes_read = bytes_read + br

      execution_stack_size, br = Marshall:read(stream)
      bytes_read = bytes_read + br

      execution_stack, br = Marshall:read(stream)
      bytes_read = bytes_read + br

      return_stack_size, br = Marshall:read(stream)
      bytes_read = bytes_read + br

      return_stack, br = Marshall:read(stream)
      bytes_read = bytes_read + br

      stack_index, br = Marshall:read(stream)
      bytes_read = bytes_read + br

      -- Restore
      assigns.stdout = StringBuffer:new(stdout, "w")
      assigns.dict = dict

      -- Lists do not have a binary format formally, so we need to hack around it
      assigns.execution_stack = List:new()
      assigns.execution_stack.m_cursor = execution_stack_size
      assigns.execution_stack.m_data = execution_stack

      --
      assigns.return_stack = List:new()
      assigns.return_stack.m_cursor = return_stack_size
      assigns.return_stack.m_data = return_stack

      assigns.stack_index = stack_index
    else
      error("unexpected version=" .. version)
    end
    return bytes_read
  end

  --- @spec bindump(OKU, Table): void
  function isa.bindump(oku, assigns, stream)
    local bytes_written = 0
    local bw, err
    bw, err = ByteBuf:w_u32(stream, 1)
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    --- STDOUT
    bw, err = Marshall:write(stream, assigns.stdout:blob())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    --- DICTIONARY
    bw, err = Marshall:write(stream, assigns.dict)
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    --- EXECUTION STACK
    bw, err = Marshall:write(stream, assigns.execution_stack:size())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    bw, err = Marshall:write(stream, assigns.execution_stack:to_table())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    --- RETURN STACK
    bw, err = Marshall:write(stream, assigns.return_stack:size())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    bw, err = Marshall:write(stream, assigns.return_stack:to_table())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    bw, err = Marshall:write(stream, assigns.stack_index)
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

  ::after::
    return bytes_written, err
  end

  --- Attempts to resolve the given word against the dictionary and builtin
  ---
  --- @spec execute_word(OKU, assigns: Table, word: String): (Boolean, err: Integer)
  function isa.execute_word(oku, assigns, word)
    local entry = assigns.dict[word] or assigns.builtin[word]

    if entry then
      if entry.is_function then
        return entry.func(isa, oku, assigns)
      elseif entry.is_def then
        isa.concat_to_execution_stack(oku, assigns, entry.def)
        assigns.cycles = assigns.cycles + 1
        return true, ISA.ERR_OK
      elseif entry.is_address then
        local ok, err = isa.stack_push(oku, assigns, entry.address)
        if ok then
          assigns.cycles = assigns.cycles + 1
          return true, ISA.ERR_OK
        else
          return false, err
        end
      elseif entry.is_value then
        local ok, err = isa.stack_push(oku, assigns, entry.value)
        if ok then
          assigns.cycles = assigns.cycles + 1
          return true, ISA.ERR_OK
        else
          return false, err
        end
      else
        return false, ISA.ERR_FATAL
      end
    end
    return false, ISA.ERR_WORD_DOES_NOT_EXIST
  end

  function isa.execution_stack_size(oku, assigns)
    return assigns.execution_stack:size()
  end

  function isa.add_to_execution_stack(oku, assigns, item)
    assigns.execution_stack:push(item)
    print(dump(assigns.execution_stack))
  end

  function isa.concat_to_execution_stack(oku, assigns, definition)
    assigns.execution_stack:reverse_concat(definition)
  end

  --- @spec memory_write(OKU, Table, addr: Integer, value: Integer): (Boolean, err: Integer)
  function isa.memory_write(oku, assigns, addr, value)
    if isa.WORD_SIZE == 1 then
      oku.memory:w_i8(addr, value)
    elseif isa.WORD_SIZE == 2 then
      oku.memory:w_i16(addr, value)
    elseif isa.WORD_SIZE == 4 then
      oku.memory:w_i32(addr, value)
    end
    return true, ISA.ERR_OK
  end

  --- @spec memory_read(OKU, Table, addr: Integer): (Boolean, value: Integer, err: Integer)
  function isa.memory_read(oku, assigns, addr)
    local value
    if isa.WORD_SIZE == 1 then
      value = oku.memory:r_i8(addr)
    elseif isa.WORD_SIZE == 2 then
      value = oku.memory:r_i16(addr)
    elseif isa.WORD_SIZE == 4 then
      value = oku.memory:r_i32(addr)
    end
    return true, value, ISA.ERR_OK
  end

  --- @spec memory_copy(OKU, Table, addr1: Integer, addr2: Integer, len: Integer): (Boolean, err: Integer)
  function isa.memory_copy(oku, assigns, addr1, add2, len)
    oku.memory:memcpy(addr1, addr2, len)
    return true, ISA.ERR_OK
  end

  function isa.stack_push(oku, assigns, number)
    local idx = assigns.stack_index - isa.WORD_SIZE

    if idx >= 0 then
      local ok, err = isa.memory_write(oku, assigns, idx, number)
      if ok then
        assigns.stack_index = idx
        return true, ISA.ERR_OK
      else
        return false, err
      end
    else
      return false, ISA.ERR_STACK_FULL
    end
  end

  function isa.stack_pop(oku, assigns)
    if assigns.stack_index < (oku.memory:size()-1) then
      local ok, value, err = isa.memory_read(oku, assigns, assigns.stack_index)
      if ok then
        assigns.stack_index = assigns.stack_index + isa.WORD_SIZE
        return true, value, ISA.ERR_OK
      else
        return false, nil, err
      end
    else
      return false, nil, ISA.ERR_STACK_EMPTY
    end
  end

  function isa.stack_peek(oku, assigns)
    if assigns.stack_index < (oku.memory:size()-1) then
      return isa.memory_read(oku, assigns, assigns.stack_index)
    else
      return false, nil, ISA.ERR_STACK_EMPTY
    end
  end

  function isa.stdout_pop(oku, assigns)
    local len = assigns.stdout:size()
    if len > 0 then
      assigns.stdout:flush()
      local value = assigns.stdout:blob()
      assigns.stdout:truncate()
      return true, value, ISA.ERR_OK
    else
      return false, nil, ISA.ERR_STDOUT_EMPTY
    end
  end

  function isa.truncate_number(oku, assigns, num)
    --- TODO: truncate
    return num
  end

  return isa
end
