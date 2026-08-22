--[[

  OKU FORTH base implementation, see OKU FORTH 8/16/32 for different cell sizes.

]]
local StringBuffer = assert(foundation.com.StringBuffer)
local List = assert(foundation.com.List)
local table_merge = assert(foundation.com.table_merge)
local ByteBuf = assert(foundation.com.ByteBuf)

--
local BB_LE = assert(ByteBuf.LE)
local MarshallV2 = foundation.com.binary_types.MarshallValue.V2:new()

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

--- @const ERR_DIVISION_BY_ZERO: Integer
ISA.ERR_DIVISION_BY_ZERO = 130

ISA.ERR_COMPILE = 140
ISA.ERR_DICTIONARY_FULL = 141
ISA.ERR_INVALID_NAME = 142
ISA.ERR_EXECUTION_STACK_FULL = 143

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
    blob = blob:gsub("%b()", " ")
    blob = blob:gsub("\\[^\r\n]*", " ")
    local result = List:new()
    local tokens = {}
    for token in blob:gmatch("%S+") do
      tokens[#tokens + 1] = token
    end

    local i = 1
    while i <= #tokens do
      local word = tokens[i]
      if word == ":" then
        local name = tokens[i + 1]
        if not name or name == ";" then
          return false, ISA.ERR_INVALID_NAME
        end

        local raw_definition = {}
        i = i + 2
        while i <= #tokens and tokens[i] ~= ";" do
          raw_definition[#raw_definition + 1] = tokens[i]
          i = i + 1
        end
        if tokens[i] ~= ";" then
          return false, ISA.ERR_COMPILE
        end

        local compile_ok, definition, compile_err = self:compile(raw_definition)
        if not compile_ok then
          return false, compile_err
        end
        local ok, err = oku:call_arch("define_word", name, definition)
        if not ok then
          return false, err
        end
      elseif word == ";" or word == "IF" or word == "ELSE" or word == "THEN" or
             word == "BEGIN" or word == "AGAIN" or word == "UNTIL" or
             word == "WHILE" or word == "REPEAT" then
        return false, ISA.ERR_COMPILE
      else
        result:push(tonumber(word) or word)
      end
      i = i + 1
    end

    return oku:call_arch("concat_to_execution_stack", result)
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

  function ic:compile_sequence(tokens, index, terminators)
    local result = {}
    while index <= #tokens do
      local word = tokens[index]
      if terminators[word] then
        return true, result, index, word
      elseif word == "IF" then
        local ok, true_body, next_index, terminal =
          self:compile_sequence(tokens, index + 1, { ELSE = true, THEN = true })
        if not ok then return false, nil, next_index end
        local false_body = {}
        if terminal == "ELSE" then
          ok, false_body, next_index, terminal =
            self:compile_sequence(tokens, next_index + 1, { THEN = true })
          if not ok then return false, nil, next_index end
        end
        if terminal ~= "THEN" then return false, nil, ISA.ERR_COMPILE end
        result[#result + 1] = {
          internal = "if",
          true_body = true_body,
          false_body = false_body,
        }
        index = next_index
      elseif word == "BEGIN" then
        local ok, first_body, next_index, terminal = self:compile_sequence(
          tokens, index + 1, { AGAIN = true, UNTIL = true, WHILE = true })
        if not ok then return false, nil, next_index end
        if terminal == "WHILE" then
          local loop_body
          ok, loop_body, next_index, terminal =
            self:compile_sequence(tokens, next_index + 1, { REPEAT = true })
          if not ok or terminal ~= "REPEAT" then
            return false, nil, ISA.ERR_COMPILE
          end
          result[#result + 1] = {
            internal = "while",
            condition = first_body,
            body = loop_body,
          }
        elseif terminal == "UNTIL" or terminal == "AGAIN" then
          result[#result + 1] = {
            internal = string.lower(terminal),
            body = first_body,
          }
        else
          return false, nil, ISA.ERR_COMPILE
        end
        index = next_index
      elseif word == "ELSE" or word == "THEN" or word == "AGAIN" or
             word == "UNTIL" or word == "WHILE" or word == "REPEAT" then
        return false, nil, ISA.ERR_COMPILE
      else
        result[#result + 1] = tonumber(word) or word
      end
      index = index + 1
    end
    if next(terminators) then return false, nil, ISA.ERR_COMPILE end
    return true, result, index
  end

  function ic:compile(tokens)
    local ok, result = self:compile_sequence(tokens, 1, {})
    if not ok then return false, nil, ISA.ERR_COMPILE end
    return true, result, ISA.ERR_OK
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
            return false, ISA.ERR_DIVISION_BY_ZERO
          else
            local quotient = n1 / n2
            if quotient < 0 then
              quotient = math.ceil(quotient)
            else
              quotient = math.floor(quotient)
            end
            local n3 = isa.truncate_number(oku, isa, quotient)
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
            return false, ISA.ERR_DIVISION_BY_ZERO
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

            ok, err = isa.memory_copy(oku, assigns, addr1, addr2, u)
            if not ok then
              return false, err
            end
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

  ["DROP"] = {
    --- (x --)
    cycles = 1,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok
      local x
      local err

      ok, x, err = isa.stack_pop(oku, assigns)
      if ok then
        assigns.cycles = assigns.cycles + 1
        return true, ISA.ERR_OK
      else
        return false, err
      end
    end,
  },

  ["NIP"] = {
    --- (x1 x2 -- x2)
    cycles = 1,
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

  ["OVER"] = {
    --- (x1 x2 -- x1 x2 x1)
    cycles = 1,
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

      ok, err = isa.stack_push(oku, assigns, x1)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

      return true, ISA.ERR_OK
    end,
  },

  ["TUCK"] = {
    --- (x1 x2 -- x2 x1 x2)
    cycles = 1,
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

      ok, err = isa.stack_push(oku, assigns, x2)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1

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
    value = 32,
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

      if assigns.return_stack:size() >= assigns.return_stack_limit then
        isa.stack_push(oku, assigns, x)
        return false, ISA.ERR_RETURN_STACK_FULL
      end
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

      if assigns.return_stack:size() + 2 > assigns.return_stack_limit then
        return false, ISA.ERR_RETURN_STACK_FULL
      end

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

local bit = assert(foundation.com.bit)

local function unary_builtin(func)
  return {
    cycles = 2,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok, value, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1
      ok, err = isa.stack_push(oku, assigns, func(isa, value))
      assigns.cycles = assigns.cycles + 1
      return ok, err
    end,
  }
end

local function binary_builtin(func)
  return {
    cycles = 3,
    is_function = true,
    func = function (isa, oku, assigns)
      local ok, rhs, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1
      local lhs
      ok, lhs, err = isa.stack_pop(oku, assigns)
      if not ok then
        return false, err
      end
      assigns.cycles = assigns.cycles + 1
      ok, err = isa.stack_push(oku, assigns, func(isa, lhs, rhs))
      assigns.cycles = assigns.cycles + 1
      return ok, err
    end,
  }
end

local function forth_bool(value)
  return value and -1 or 0
end

ISA.forth_builtin["="] = binary_builtin(function (_, a, b) return forth_bool(a == b) end)
ISA.forth_builtin["<>"] = binary_builtin(function (_, a, b) return forth_bool(a ~= b) end)
ISA.forth_builtin["<"] = binary_builtin(function (_, a, b) return forth_bool(a < b) end)
ISA.forth_builtin[">"] = binary_builtin(function (_, a, b) return forth_bool(a > b) end)
ISA.forth_builtin["0="] = unary_builtin(function (_, a) return forth_bool(a == 0) end)
ISA.forth_builtin["0<"] = unary_builtin(function (_, a) return forth_bool(a < 0) end)
ISA.forth_builtin.AND = binary_builtin(function (_, a, b) return bit.band(a, b) end)
ISA.forth_builtin.OR = binary_builtin(function (_, a, b) return bit.bor(a, b) end)
ISA.forth_builtin.XOR = binary_builtin(function (_, a, b) return bit.bxor(a, b) end)
ISA.forth_builtin.INVERT = unary_builtin(function (_, a) return bit.bnot(a) end)
ISA.forth_builtin.LSHIFT = binary_builtin(function (isa, a, b)
  if b < 0 or b >= isa.BIT_COUNT then return 0 end
  return bit.lshift(a, b)
end)
ISA.forth_builtin.RSHIFT = binary_builtin(function (isa, a, b)
  if b < 0 or b >= isa.BIT_COUNT then return 0 end
  return bit.rshift(bit.band(a, isa.UI_MAX), b)
end)

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
    assigns.dict_used = 0
    assigns.dict_count = 0
    --- The execution stack contains either WORDs or NUMBERs.
    --- As its name suggests these values are popped and interpreted during the step.
    assigns.execution_stack = List:new()
    --- The return stack contains the position in the execution stack to return to
    --- upon early return the execution stack will be truncated to the value popped from this
    assigns.return_stack = List:new()
    assigns.return_stack_limit = 256
    assigns.execution_stack_limit = 4096

    --- The stack starts at the maximum memory size, and decrements upon use and increments upon
    --- being popped, it is up to the user to ensure their stack doesn't bleed into their usable
    --- memory, which is the entire range
    --- The stack is zero indexed.
    assigns.stack_index = oku.memory:size()
  end

  --- @spec dispose(OKU, Table): void
  function isa.dispose(oku, assigns)
    --
  end

  --- @spec reset(OKU, Table): void
  function isa.reset(oku, assigns)
    isa.init(oku, assigns)
  end

  function isa.eval(oku, assigns, blob)
    return isa.compiler:eval(oku, blob)
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
        elseif ty == "table" then
          ok, err = isa.execute_internal(oku, assigns, item)
          if not ok then
            return false, err
          end
        else
          return false, ISA.ERR_FATAL
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
    version, br = BB_LE:r_u32(stream)
    if version == 1 or version == 2 then
      local stdout
      local dict
      local execution_stack_size
      local execution_stack
      local return_stack_size
      local return_stack
      local stack_index

      stdout, br = MarshallV2:read(BB_LE, stream)
      bytes_read = bytes_read + br

      dict, br = MarshallV2:read(BB_LE, stream)
      bytes_read = bytes_read + br

      if version == 2 then
        local dictionary_size
        dictionary_size, br = MarshallV2:read(BB_LE, stream)
        bytes_read = bytes_read + br
        if dictionary_size > oku.dictionary_size then
          error("saved dictionary exceeds configured dictionary_size")
        end
      end

      execution_stack_size, br = MarshallV2:read(BB_LE, stream)
      bytes_read = bytes_read + br

      execution_stack, br = MarshallV2:read(BB_LE, stream)
      bytes_read = bytes_read + br

      return_stack_size, br = MarshallV2:read(BB_LE, stream)
      bytes_read = bytes_read + br

      return_stack, br = MarshallV2:read(BB_LE, stream)
      bytes_read = bytes_read + br

      stack_index, br = MarshallV2:read(BB_LE, stream)
      bytes_read = bytes_read + br

      -- Restore
      assigns.stdout = StringBuffer:new(stdout or "", "w")
      assigns.builtin = builtin
      assigns.dict = dict
      assigns.dict_used = 0
      assigns.dict_count = 0
      for _, entry in pairs(dict) do
        assigns.dict_used = assigns.dict_used + (entry.cost or 0)
        assigns.dict_count = assigns.dict_count + 1
      end
      if assigns.dict_used > oku.dictionary_size or assigns.dict_count > 256 then
        error("saved dictionary exceeds configured limits")
      end

      -- Lists do not have a binary format formally, so we need to hack around it
      assigns.execution_stack = List:new()
      assigns.execution_stack.m_cursor = execution_stack_size
      assigns.execution_stack.m_data = execution_stack

      --
      assigns.return_stack = List:new()
      assigns.return_stack.m_cursor = return_stack_size
      assigns.return_stack.m_data = return_stack
      assigns.return_stack_limit = 256
      assigns.execution_stack_limit = 4096

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
    bw, err = BB_LE:w_u32(stream, 2)
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    --- STDOUT
    bw, err = MarshallV2:write(BB_LE, stream, assigns.stdout:blob())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    --- DICTIONARY
    bw, err = MarshallV2:write(BB_LE, stream, assigns.dict)
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    bw, err = MarshallV2:write(BB_LE, stream, oku.dictionary_size)
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    --- EXECUTION STACK
    bw, err = MarshallV2:write(BB_LE, stream, assigns.execution_stack:size())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    bw, err = MarshallV2:write(BB_LE, stream, assigns.execution_stack:to_table())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    --- RETURN STACK
    bw, err = MarshallV2:write(BB_LE, stream, assigns.return_stack:size())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    bw, err = MarshallV2:write(BB_LE, stream, assigns.return_stack:to_table())
    bytes_written = bytes_written + bw
    if err then
      goto after
    end

    bw, err = MarshallV2:write(BB_LE, stream, assigns.stack_index)
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
    local upper_word = string.upper(word)
    local entry = assigns.dict[upper_word] or assigns.builtin[word] or
                  assigns.builtin[upper_word] or assigns.builtin[string.lower(word)]

    if entry then
      if entry.is_function then
        return entry.func(isa, oku, assigns)
      elseif entry.is_def then
        local ok, err = isa.concat_to_execution_stack(oku, assigns, entry.def)
        if not ok then return false, err end
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

  function isa.execute_internal(oku, assigns, token)
    local op = token.internal
    if op == "if" then
      local ok, flag, err = isa.stack_pop(oku, assigns)
      if not ok then return false, err end
      isa.concat_to_execution_stack(
        oku, assigns, flag ~= 0 and token.true_body or token.false_body)
    elseif op == "until" or op == "again" then
      assigns.execution_stack:push({ internal = op .. "_check", loop = token })
      isa.concat_to_execution_stack(oku, assigns, token.body)
    elseif op == "until_check" then
      local ok, flag, err = isa.stack_pop(oku, assigns)
      if not ok then return false, err end
      if flag == 0 then assigns.execution_stack:push(token.loop) end
    elseif op == "again_check" then
      assigns.execution_stack:push(token.loop)
    elseif op == "while" then
      assigns.execution_stack:push({ internal = "while_check", loop = token })
      isa.concat_to_execution_stack(oku, assigns, token.condition)
    elseif op == "while_check" then
      local ok, flag, err = isa.stack_pop(oku, assigns)
      if not ok then return false, err end
      if flag ~= 0 then
        assigns.execution_stack:push(token.loop)
        isa.concat_to_execution_stack(oku, assigns, token.loop.body)
      end
    else
      return false, ISA.ERR_FATAL
    end
    assigns.cycles = assigns.cycles + 1
    return true, ISA.ERR_OK
  end

  function isa.execution_stack_size(oku, assigns)
    return assigns.execution_stack:size()
  end

  local function token_cost(token)
    if type(token) == "number" then
      return 4
    elseif type(token) == "string" then
      return 1 + #token
    elseif type(token) == "table" then
      local cost = 4
      for _, key in ipairs({ "true_body", "false_body", "condition", "body" }) do
        if token[key] then
          for _, child in ipairs(token[key]) do
            cost = cost + token_cost(child)
          end
        end
      end
      return cost
    end
    return 0
  end

  local function definition_cost(name, definition)
    local cost = 8 + #name
    for _, token in ipairs(definition) do
      cost = cost + token_cost(token)
    end
    return cost
  end

  function isa.define_word(oku, assigns, name, definition)
    name = string.upper(name)
    if name == "" or #name > 64 or name == ":" or name == ";" then
      return false, ISA.ERR_INVALID_NAME
    end
    if #definition > 1024 then
      return false, ISA.ERR_DICTIONARY_FULL
    end

    local old_entry = assigns.dict[name]
    if not old_entry and assigns.dict_count >= 256 then
      return false, ISA.ERR_DICTIONARY_FULL
    end

    local cost = definition_cost(name, definition)
    local old_cost = old_entry and old_entry.cost or 0
    local new_used = assigns.dict_used - old_cost + cost
    if new_used > oku.dictionary_size then
      return false, ISA.ERR_DICTIONARY_FULL
    end

    assigns.dict[name] = {
      is_def = true,
      def = definition,
      cost = cost,
    }
    assigns.dict_used = new_used
    if not old_entry then
      assigns.dict_count = assigns.dict_count + 1
    end
    return true, ISA.ERR_OK
  end

  function isa.add_to_execution_stack(oku, assigns, item)
    if assigns.execution_stack:size() >= assigns.execution_stack_limit then
      return false, ISA.ERR_EXECUTION_STACK_FULL
    end
    assigns.execution_stack:push(item)
    return true, ISA.ERR_OK
  end

  function isa.concat_to_execution_stack(oku, assigns, definition)
    local definition_size = definition.size and definition:size() or #definition
    if assigns.execution_stack:size() + definition_size > assigns.execution_stack_limit then
      return false, ISA.ERR_EXECUTION_STACK_FULL
    end
    assigns.execution_stack:reverse_concat(definition)
    return true, ISA.ERR_OK
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
  function isa.memory_copy(oku, assigns, addr1, addr2, len)
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
    if assigns.stack_index < oku.memory:size() then
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
    if assigns.stack_index < oku.memory:size() then
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
