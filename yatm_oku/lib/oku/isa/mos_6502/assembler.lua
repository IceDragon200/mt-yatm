--
-- Below is a set of modules for assembling 6502 assembly into its binary form
-- This can then be executed by the OKU 6502.
-- This comes with a full lexer as well, so you could theorectically use
-- it for other stuff.
--
local StringBuf = assert(yatm_core.StringBuf)

local TokenBuffer = yatm_core.Class:extends("TokenBuffer")
local ic = TokenBuffer.instance_class

local function _check_writable(self)
  assert(self.m_mode == 'w' or self.m_mode == 'rw')
end

function ic:initialize(tokens, mode)
  self.m_mode = mode
  self.m_data = tokens or {}
  self:open(mode)
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
  self.m_cursor = self.m_cursor + distance
  return self
end

function ic:push_token(token_name, data)
  _check_writable(self)
  self.m_data[self.m_cursor] = {token_name, data}
  self.m_cursor = self.m_cursor + 1
end

local function tokens_match(token, matcher)
  return token[1] == matcher
end

-- @doc Returns a list of the matched tokens, or nil if no match
--
-- @spec :scan(...tokens :: [String]) :: [Token] | nil
function ic:scan(...)
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

  return tokens
end

function ic:scan_until(token_name)
  local i = 1
  local len = #self.m_data
  local tokens = {}

  local j = self.m_cursor
  while j <= len do
    if self.m_data[j] then
      table.insert(tokens, self.m_data[j])
      if tokens_match(self.m_data[j], token_name) then
        self.m_cursor = j + 1
        break
      end
    else
      break
    end
    j = j + 1
  end

  return tokens
end

function ic:scan_upto(token_name)
  local len = #self.m_data
  local tokens = {}

  local j = self.m_cursor
  while j <= len do
    if self.m_data[j] then
      if tokens_match(self.m_data[j], token_name) then
        self.m_cursor = j
        break
      else
        table.insert(tokens, self.m_data[j])
      end
    else
      break
    end
    j = j + 1
  end

  return tokens
end

-- @doc Checks if all the given token names match the curre
--
-- @spec :match_tokens(...tokens :: [String]) :: boolean
function ic:match_tokens(...)
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
  local int = buf:scan("%d")
  if int then
    result:push_token("integer", int)
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

  print(dump(result.m_data))

  return result, buf:read()
end

local Assembler = {
  TokenBuffer = TokenBuffer,
  Lexer = Lexer,
}

local m = Assembler

yatm_oku.OKU.isa.MOS6502.Assembler = Assembler
