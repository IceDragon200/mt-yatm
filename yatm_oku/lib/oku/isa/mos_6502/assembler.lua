--
-- Below is a set of modules for assembling 6502 assembly into its binary form
-- This can then be executed by the OKU 6502.
-- This comes with a full lexer as well, so you could theorectically use
-- it for other stuff.
--
local StringBuf = assert(yatm_core.StringBuf)

local function tokens_match(token, matcher)
  return token[1] == matcher
end

local function match_tokens(tokens, start, stop, token_matchers)
  local i = 1
  local len = #tokens

  local matched = false
  local j = start
  while j <= len and i <= stop do
    if tokens[j] then
      local token = tokens[j]
      local matcher_token = token_matchers[i]

      if tokens_match(token, matcher_token) then
        matched = true
      else
        return false
      end
    else
      return false
    end
    i = i + 1
    j = j + 1
  end

  return matched
end

local TokenBuffer = yatm_core.Class:extends("TokenBuffer")
local ic = TokenBuffer.instance_class

local function _check_readable(self)
  assert(self.m_mode == 'r' or self.m_mode == 'rw')
end

local function _check_writable(self)
  assert(self.m_mode == 'w' or self.m_mode == 'rw' or self.m_mode == 'a')
end

function ic:initialize(tokens, mode)
  self.m_mode = mode
  self.m_data = tokens or {}
  self:open(mode)
end

function ic:seek(cursor)
  self.m_cursor = cursor
  return self
end

function ic:isEOB()
  return self.m_cursor > #self.m_data
end

function ic:to_list()
  return yatm_core.table_copy(self.m_data)
end

function ic:open(mode)
  self.m_cursor = 1
  self.m_mode = mode or "r"
  -- append
  if self.m_mode == "a" then
    self.m_cursor = 1 + #self.m_data
  end
  return self
end

function ic:walk(distance)
  _check_readable(self)
  self.m_cursor = self.m_cursor + distance
  return self
end

function ic:push(token)
  _check_writable(self)
  self.m_data[self.m_cursor] = token
  self.m_cursor = self.m_cursor + 1
  return self
end

function ic:push_token(token_name, data)
  return self:push({token_name, data})
end

function ic:skip(token_name)
  _check_readable(self)
  if not self:isEOB() then
    local token = self.m_data[self.m_cursor]
    if tokens_match(token, token_name) then
      self.m_cursor = self.m_cursor + 1
      return true
    end
  end
  return false
end

function ic:peek(count)
  return yatm_core.list_slice(self.m_data, self.m_cursor, count)
end

-- @doc Returns a list of the matched tokens, or nil if no match
--
-- @spec :scan(...tokens :: [String]) :: [Token] | nil
function ic:scan(...)
  _check_readable(self)
  local token_matchers = {...}
  local token_matchers_len = #token_matchers

  local i = 1
  local len = #self.m_data

  local tokens = {}

  local j = self.m_cursor
  while j <= len and i <= token_matchers_len do
    if self.m_data[j] then
      local token = self.m_data[j]
      local matcher_token = token_matchers[i]

      if tokens_match(token, matcher_token) then
        table.insert(tokens, token)
      else
        return nil
      end
    else
      return nil
    end
    i = i + 1
    j = j + 1
  end
  self.m_cursor = j
  return tokens
end

function ic:scan_one(token_name)
  local tokens = self:scan(token_name)
  if tokens then
    return tokens[1]
  end
  return nil
end

function ic:scan_until(token_name)
  _check_readable(self)
  local i = 1
  local len = #self.m_data
  local tokens = {}

  local j = self.m_cursor
  while j <= len do
    if self.m_data[j] then
      table.insert(tokens, self.m_data[j])
      if tokens_match(self.m_data[j], token_name) then
        break
      end
    else
      break
    end
    j = j + 1
  end
  self.m_cursor = j

  return tokens
end

function ic:scan_upto(token_name)
  _check_readable(self)
  local len = #self.m_data
  local tokens = {}

  local j = self.m_cursor
  while j <= len do
    if self.m_data[j] then
      if tokens_match(self.m_data[j], token_name) then
        break
      else
        table.insert(tokens, self.m_data[j])
      end
    else
      break
    end
    j = j + 1
  end
  self.m_cursor = j

  return tokens
end

-- @doc Checks if all the given token names match the curre
--
-- @spec :match_tokens(...tokens :: [String]) :: boolean
function ic:match_tokens(...)
  _check_readable(self)
  local token_matchers = {...}
  local token_matchers_len = #token_matchers
  return match_tokens(self.m_data, self.m_cursor, token_matchers_len, token_matchers)
end

local Lexer = {}
local m = Lexer

local function tokenize_comment(buf, result)
  if buf:scan(";") then -- skip the semicolon
    local comment = buf:scan_upto("\n") or buf:read()
    result:push_token("comment", comment)
    return true
  end
  return false
end

local function tokenize_comma(buf, result)
  if buf:scan(",") then -- skip the comma
    result:push_token(",", true)
    return true
  end
  return false
end

local function tokenize_colon(buf, result)
  if buf:scan(":") then -- skip the colon
    result:push_token(":", true)
    return true
  end
  return false
end

local function tokenize_hash(buf, result)
  if buf:scan("#") then -- skip the hash
    result:push_token("#", true)
    return true
  end
  return false
end

local function tokenize_open_round_bracket(buf, result)
  if buf:scan("%(") then -- skip the bracket
    result:push_token("(", true)
    return true
  end
  return false
end

local function tokenize_close_round_bracket(buf, result)
  if buf:scan("%)") then -- skip the bracket
    result:push_token(")", true)
    return true
  end
  return false
end

local function tokenize_newlines(buf, result)
  if buf:scan_while("\n+") then -- skip as many newlines as possible
    result:push_token("nl", true)
    return true
  end
  return false
end

local function tokenize_spaces(buf, result)
  if buf:scan_while("[ \t]+") then -- skip as many spaces and tabs as possible
    result:push_token("ws", true)
    return true
  end
  return false
end

local function tokenize_dquote(buf, result)
  if buf:scan("\"") then
    local contents = {}
    local i = 1
    while not buf:isEOF() do
      local blob = buf:scan_upto("[\\\"]")
      if not blob then
        return false
      end
      contents[i] = blob
      i = i + 1
      local nxt = buf:read(1)
      if nxt == "\\" then
        -- escape sequence
        local nxt = buf:read(1)

        if nxt == "0" then
          -- null
          contents[i] = "\0"
        elseif nxt == "s" then
          -- space
          contents[i] = " "
        elseif nxt == "r" then
          -- line return
          contents[i] = "\r"
        elseif nxt == "n" then
          -- newline
          contents[i] = "\n"
        elseif nxt == "t" then
          -- tab
          contents[i] = "\t"
        else
          contents[i] = nxt
        end
        i = i + 1
      elseif nxt == "\"" then
        -- end of string
        result:push_token("dquote", table.concat(contents))
        break
      else
        error("something... odd happened")
      end
    end

    return true
  end
  return false
end

local function tokenize_squote(buf, result)
  if buf:scan("'") then
    local contents = {}
    local blob = buf:scan_upto("'")
    if blob then
      buf:walk(1)
      result:push_token("squote", blob)
      return true
    end
  end
  return false
end

local function tokenize_atom(buf, result)
  local atom = buf:scan("[%a_][_%a%d]*")
  if atom then
    result:push_token("atom", atom)
    return true
  end
  return false
end

local function tokenize_dollar_hex(buf, result)
  local hex = buf:scan("%$[0-9A-Fa-f]+")
  if hex then
    result:push_token("hex", string.sub(hex, 2))
    return true
  end
  return false
end

local function tokenize_integer(buf, result)
  local int = buf:scan("%d+")
  if int then
    result:push_token("integer", tonumber(int))
    return true
  end
  return false
end

local function tokenize_value(buf, result)
  if tokenize_atom(buf, result) then
    return true
  end
  if tokenize_dollar_hex(buf, result) then
    return true
  end
  if tokenize_integer(buf, result) then
    return true
  end
  return false
end

-- @spec tokenize(String) :: TokenBuffer, String
function Lexer.tokenize(str)
  local buf = StringBuf:new(str, 'r')

  local result = TokenBuffer:new({}, 'w')

  while not buf:isEOF() do
    local next_char = buf:peek(1)

    if next_char == ";" then
      tokenize_comment(buf, result)
    elseif next_char == "," then
      tokenize_comma(buf, result)
    elseif next_char == ":" then
      tokenize_colon(buf, result)
    elseif next_char == "#" then
      tokenize_hash(buf, result)
    elseif next_char == "(" then
      tokenize_open_round_bracket(buf, result)
    elseif next_char == ")" then
      tokenize_close_round_bracket(buf, result)
    elseif next_char == "\n" then
      tokenize_newlines(buf, result)
    elseif next_char == "\"" then
      tokenize_dquote(buf, result)
    elseif next_char == "'" then
      tokenize_squote(buf, result)
    elseif next_char == " " or next_char == "\t" then
      tokenize_spaces(buf, result)
    else
      if not tokenize_value(buf, result) then
        break
      end
    end
  end

  return result, buf:read()
end

local Parser = {}
local m = Parser

local function atom_value(token)
  return token[2]
end

local function parse_comment(token_buf, result)
  if token_buf:scan("ws", "comment", "nl") then
    return true
  elseif token_buf:scan("comment", "nl") then
    return true
  elseif token_buf:scan("ws", "comment") then
    return true
  elseif token_buf:skip("comment") then
    return true
  end
  return false
end

local function parse_label(token_buf, result)
  local tokens = token_buf:scan("atom", ":")
  if tokens then
    result:push_token("label", atom_value(tokens[1]))
    return true
  end
  return false
end

local function parse_line_term(token_buf, result)
  if token_buf:scan("ws", "nl") then
    return true
  elseif token_buf:scan("nl") then
    return true
  elseif token_buf:scan("ws", "comment", "nl") then
    return true
  elseif token_buf:scan("comment", "nl") then
    return true
  end
  return false
end

local function parse_register_name_or_atom(token_buf)
  local token = token_buf:scan_one("atom")
  if token then
    local name = atom_value(token)

    if name == "X" or name == "x" then
      return {"register_x", true}
    elseif name == "Y" or name == "y" then
      return {"register_y", true}
    else
      -- return a new atom
      return {"atom", name}
    end
  end
  return nil
end

local function hex_token_to_byte(token)
  local hex_value = token[2]
  if #hex_value < 2 then
    -- TODO: issue warning, the value was padded
    hex_value = yatm_core.string_pad_leading(hex_value, 2, "0")
  elseif #hex_value > 2 then
    -- TODO: issue warning, the value was truncated
    hex_value = yatm_core.string_rsub(hex_value, 2)
  end
  return yatm_core.string_hex_pair_to_byte(hex_value)
end

local function hex_token_to_num(token)
  local hex_value = token[2]
  if #hex_value > 2 then
    hex_value = yatm_core.string_pad_leading(hex_value, 4, "0")
    hex_value = yatm_core.string_rsub(hex_value, 4)
    local hipair = string.sub(hex_value, 1, 2)
    local lopair = string.sub(hex_value, 3, 4)
    return hipair * 256 + lopair
  else
    return hex_token_to_byte(token)
  end
end

local function parse_absolute_or_zeropage_address(token_buf)
  local token = token_buf:scan_one("integer") or token_buf:scan_one("hex")

  if token then
    if token[1] == "hex" then
      local hex_value = token[2]
      if #hex_value <= 2 then
        hex_value = yatm_core.string_pad_leading(hex_value, 2, "0")
        local value = yatm_core.string_hex_pair_to_byte(hex_value)
        return {"zeropage", value}
      else
        hex_value = yatm_core.string_pad_leading(hex_value, 4, "0")
        hex_value = yatm_core.string_rsub(hex_value, 4)
        local hipair = string.sub(hex_value, 1, 2)
        local lopair = string.sub(hex_value, 3, 4)
        return {"absolute", hipair * 256 + lopair}
      end
    else
      local value = token[2]
      if value > 255 then
        return {"absolute", value}
      else
        return {"zeropage", value}
      end
    end
  end
  return nil
end

local function parse_immediate(token_buf)
  local tokens = token_buf:scan("#", "hex") or token_buf:scan("#", "integer")
  if tokens then
    local token = tokens[2]
    local value
    if token[1] == "hex" then
      value = hex_token_to_byte(token)
    elseif token[1] == "integer" then
      value = math.min(math.max(-128, token[2]), 255)
    else
      error("expected an integer or hex")
    end
    return {"immediate", value}
  end
  return nil
end

local function parse_indirect_offset(token_buf)
  if token_buf:skip("(") then
    local result = {}
    while not token_buf:isEOB() do
      token_buf:skip("ws") -- skip leading spaces
      local token = token_buf:scan_one("hex") or
                    token_buf:scan_one("integer") or
                    parse_register_name_or_atom(token_buf)
      if token then
        table.insert(result, token)
        token_buf:skip("ws")
        if token_buf:skip(",") then
          -- can continue
        else
          break
        end
      else
        break
      end
    end

    token_buf:skip("ws") -- skip trailing spaces

    if token_buf:skip(")") then
      if #result == 2 then
        if match_tokens(result, 1, #result, {"hex", "register_x"}) then
          return {"indirect_x", hex_token_to_byte(result[1])}
        elseif match_tokens(result, 1, #result, {"integer", "register_x"}) then
          return {"indirect_x", result[1][2]}
        else
          error("unexpected indirect args")
        end
      elseif #result == 1 then
        if match_tokens(result, 1, #result, {"hex"}) then
          return {"indirect", hex_token_to_num(result[1])}
        elseif match_tokens(result, 1, #result, {"integer"}) then
          return {"indirect", result[1][2]}
        else
          error("unexpected token")
        end
      else
        error("invalid number of arguments expected 1 or 2 got " .. #result)
      end
    else
      error("invalid indirect syntax, expected (hex | integer[,atom])")
    end
  end

  return nil
end

local function parse_ins_arg(token_buf)
  return parse_register_name_or_atom(token_buf) or
         parse_absolute_or_zeropage_address(token_buf) or
         parse_immediate(token_buf) or
         parse_indirect_offset(token_buf)
end

local function tokens_to_addressing_mode(result)
  --
  -- TODO: Support variable substitution
  --   Example:
  --     ADC #word
  --     ADC word
  --
  if #result == 0 then
    return {}
  elseif #result == 1 then
    if match_tokens(result, 1, 1, {"indirect_x"}) then
      return result
    elseif match_tokens(result, 1, 1, {"absolute"}) then
      return result
    elseif match_tokens(result, 1, 1, {"immediate"}) then
      return result
    elseif match_tokens(result, 1, 1, {"zeropage"}) then
      return result
    elseif match_tokens(result, 1, 1, {"register_a"}) then
      return result
    else
      error("invalid 1 argument pattern")
    end
  elseif #result == 2 then
    if match_tokens(result, 1, 2, {"absolute", "register_x"}) then
      return {{"absolute_x", result[1][2]}}
    elseif match_tokens(result, 1, 2, {"absolute", "register_y"}) then
      return {{"absolute_y", result[1][2]}}
    elseif match_tokens(result, 1, 2, {"indirect", "register_y"}) then
      return {{"indirect_y", result[1][2]}}
    elseif match_tokens(result, 1, 2, {"zeropage", "register_y"}) then
      return {{"zeropage_y", result[1][2]}}
    elseif match_tokens(result, 1, 2, {"zeropage", "register_x"}) then
      return {{"zeropage_x", result[1][2]}}
    else
      error("invalid 2 argument pattern")
    end
  else
    error("invalid number of arguments expected 0, 1 or 2 got " .. #result)
  end
end

local function parse_ins_args(token_buf)
  local result = {}
  while not token_buf:isEOB() do
    token_buf:skip("ws")
    local token = parse_ins_arg(token_buf)
    if token then
      table.insert(result, token)
      token_buf:skip("ws")
      if token_buf:skip(",") then
        --
      else
        break
      end
    else
      break
    end
  end

  return tokens_to_addressing_mode(result)
end

local function parse_ins(token_buf, result)
  token_buf:skip("ws")
  local ins = token_buf:scan_one("atom")
  if ins then
    local args = parse_ins_args(token_buf)
    parse_line_term(token_buf, result)
    result:push_token("ins", {
      name = string.lower(atom_value(ins)),
      args = args
    })
    return true
  end
  return false
end

function m.parse(token_buf)
  local result = TokenBuffer:new({}, 'w')

  while not token_buf:isEOB() do
    if parse_line_term(token_buf, result) then
      --
    elseif parse_label(token_buf, result) then
      --
    elseif parse_ins(token_buf, result) then
      --
    else
      break
    end
  end
  return result
end

dofile(yatm_oku.modpath .. "/lib/oku/isa/mos_6502/nmos_assembly.lua")

local NMOS_Assembly = assert(yatm_oku.OKU.isa.MOS6502.NMOS_Assembly)
local AssemblyBuilder = assert(yatm_oku.OKU.isa.MOS6502.Builder)
local Assembler = {
  TokenBuffer = TokenBuffer,
  Lexer = Lexer,
  Parser = Parser,
}

local m = Assembler

function m.parse(prog)
  local token_buf, rest = m.Lexer.tokenize(prog)
  token_buf:open('r')
  return m.Parser.parse(token_buf), rest
end

function m.assemble_tokens(token_buf)
  local tokens = token_buf:to_list()

  local context = {
    -- yes, a zero index
    pos = 0,
    -- TODO: actually use the jump table
    jump_table = {},
  }

  local result = {}
  local result_i = 1

  local function push_binary(binary)
    result[result_i] = binary
    result_i = result_i + 1
    context.pos = context.pos + #binary
  end

  for _, token in ipairs(tokens) do
    if token[1] == "ins" then
      local ins_name = token[2].name
      local ins_args = token[2].args

      local branch = NMOS_Assembly[ins_name]
      if branch then
        local leaf
        if #ins_args == 0 then
          leaf = branch["implied"]
          if leaf then
            local binary = AssemblyBuilder[leaf]()
            push_binary(binary)
          else
            error("invalid instruction " .. ins_name .. " with arg pattern " .. arg[1])
          end
        else
          local arg = assert(ins_args[1])
          leaf = branch[arg[1]]
          if leaf then
            local binary = AssemblyBuilder[leaf](arg[2])
            push_binary(binary)
          else
            error("invalid instruction " .. ins_name .. " with arg pattern " .. arg[1])
          end
        end
      else
        error("no such instruction " .. ins_name)
      end
    elseif token[1] == "label" then
      context.jump_table[token[2]] = context.pos
    else
      error("unexpected token " .. token[1])
    end
  end

  return table.concat(result), context
end

-- @spec assemble(String) :: (binary :: String, error :: String)
function m.assemble(prog)
  local tokens, rest = m.parse(prog)

  local blob, context = m.assemble_tokens(tokens)
  return blob, context, rest
end

-- @spec assemble_safe(String) :: (boolean, binary :: String, error :: String)
function m.assemble_safe(prog)
  local result, blob, context, rest =
    pcall(function ()
      return m.assemble(prog)
    end)

  if result then
    return true, blob, context, rest
  else
    return false, blob
  end
end

yatm_oku.OKU.isa.MOS6502.Assembler = Assembler
