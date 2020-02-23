--
-- Below is a set of modules for assembling 6502 assembly into its binary form
-- This can then be executed by the OKU 6502.
-- This comes with a full lexer as well, so you could theorectically use
-- it for other stuff.
--
local StringBuf = assert(yatm_core.StringBuf)

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

local function tokens_match(token, matcher)
  return token[1] == matcher
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

  local i = 1
  local len = #self.m_data

  local matched = false
  local j = self.m_cursor
  while j <= len and i <= token_matchers_len do
    if self.m_data[j] then
      local token = self.m_data[j]
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

local function parse_indirect_offset(token_buf)
  if token_buf:skip("(") then
    local result = {}
    while not token_buf:isEOB() do
      token_buf:skip("ws") -- skip leading spaces
      local value = token_buf:scan("hex") or
                    token_buf:scan("integer")
      if value then
        table.insert(result, value[1])
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
      return {"indirect", result}
    else
      error("invalid indirect syntax, expected (hex | integer[,hex | integer])")
    end
  end

  return nil
end

local function parse_immediate(token_buf)
  local tokens = token_buf:scan("#", "hex") or token_buf:scan("#", "integer")
  if tokens then
    return {"immediate", tokens[2]}
  end
  return nil
end

local function parse_ins_arg(token_buf)
  return token_buf:scan_one("atom") or
         token_buf:scan_one("integer") or
         token_buf:scan_one("hex") or
         parse_immediate(token_buf) or
         parse_indirect_offset(token_buf)
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
  return result
end

local function parse_ins(token_buf, result)
  token_buf:skip("ws")
  local ins = token_buf:scan_one("atom")
  if ins then
    local args = parse_ins_args(token_buf)
    parse_line_term(token_buf, result)
    result:push_token("ins", { name = atom_value(ins), args = args })
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

local Assembler = {
  TokenBuffer = TokenBuffer,
  Lexer = Lexer,
  Parser = Parser,
}

local m = Assembler

function m.parse(prog)
  local token_buf = m.Lexer.tokenize(prog)
  token_buf:open('r')
  return m.Parser.parse(token_buf)
end

function m.assemble_tokens(token_buf)
  local tokens = token_buf:to_list()

  local pos = 0
  local pos_table = {}

  for _, token in ipairs(tokens) do
    if token[1] == "ins" then
    elseif token[1] == "label" then
    end
  end
end

-- @spec assemble(String) :: (binary :: String, error :: String)
function m.assemble(prog)
  local tokens = m.parse(prog)

  return m.assemble_tokens(parsed_tokens)
end

yatm_oku.OKU.isa.MOS6502.Assembler = Assembler
