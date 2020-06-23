local StringBuf = assert(yatm_core.StringBuf)
local TokenBuffer = assert(yatm_oku.TokenBuffer)

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

yatm_oku.OKU.isa.MOS6502.Lexer = Lexer
