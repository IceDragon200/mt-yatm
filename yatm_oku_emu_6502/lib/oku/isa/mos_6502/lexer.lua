--- @namespace yatm_oku.OKU.isa.MOS6502.Lexer

local StringBuffer = assert(foundation.com.StringBuffer)
local TokenBuffer = assert(yatm_oku.TokenBuffer)

local SC = string.byte(";")
local CM = string.byte(",")
local CO = string.byte(":")
local CR = string.byte("\r")
local LF = string.byte("\n")
local HASH = string.byte("#")
local ORBL = string.byte("(")
local ORBR = string.byte(")")
local DQUOTE = string.byte("\"")
local SQUOTE = string.byte("'")
local SPACE = string.byte(" ")
local TAB = string.byte("\t")
local DOT = string.byte(".") -- or period, but dot is easier to write

local Lexer = foundation.com.Class:extends("yatm_oku.OKU.isa.MOS6502.Lexer")
do
  local ic = Lexer.instance_class

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)
  end

  --- @spec tokenize_comment(buf: StringBuffer, result: TokenBuffer): Boolean
  function ic:tokenize_comment(buf, result)
    local pos = buf:tell()
    local v
    local len
    v = buf:scan_raw("^;")
    if v then -- skip the semicolon
      local comment
      comment, len = buf:scan_upto("\n")
      if not comment then
        comment, len = buf:read()
      end
      result:push_token("comment", comment, { pos = pos, len = len + 1 })
      return true
    end
    return false
  end

  function ic:tokenize_comma(buf, result)
    local pos = buf:tell()
    local v, len = buf:scan_raw("^,")
    if v then -- skip the comma
      result:push_token(",", true, { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_colon(buf, result)
    local pos = buf:tell()
    local v, len = buf:scan_raw("^:")
    if v then -- skip the colon
      result:push_token(":", true, { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_hash(buf, result)
    local pos = buf:tell()
    local v, len = buf:scan_raw("^#")
    if v then -- skip the hash
      result:push_token("#", true, { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_open_round_bracket(buf, result)
    local pos = buf:tell()
    local v, len = buf:scan_raw("^%(")
    if v then -- skip the bracket
      result:push_token("(", true, { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_close_round_bracket(buf, result)
    local pos = buf:tell()
    local v, len = buf:scan_raw("^%)")
    if v then -- skip the bracket
      result:push_token(")", true, { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_newlines(buf, result)
    local pos = buf:tell()
    local nl, len = buf:scan_while("[\n\r]+")
    if nl then -- skip as many newlines as possible
      result:push_token("nl", nl, { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_spaces(buf, result)
    local pos = buf:tell()
    local ws, len = buf:scan_while("[ \t]+")
    if ws then -- skip as many spaces and tabs as possible
      result:push_token("ws", ws, { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_dquote(buf, result)
    local pos = buf:tell()
    if buf:scan("\"") then
      local contents = {}
      local i = 1
      local blob
      local nxt
      while not buf:isEOF() do
        blob = buf:scan_upto("[\\\"]")
        if not blob then
          return false
        end
        contents[i] = blob
        i = i + 1
        nxt = buf:read(1)
        if nxt == "\\" then
          -- escape sequence
          nxt = buf:read(1)

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
          result:push_token(
            "dquote",
            table.concat(contents),
            { pos = pos, len = buf:tell() - pos }
          )
          break
        else
          error("something... odd happened")
        end
      end

      return true
    end
    return false
  end

  function ic:tokenize_squote(buf, result)
    local pos = buf:tell()
    if buf:scan("'") then
      local contents = {}
      local blob = buf:scan_upto("'")
      if blob then
        buf:walk(1)
        result:push_token("squote", blob, { pos = pos, len = buf:tell() - pos  })
        return true
      end
    end
    return false
  end

  --- @spec #tokenize_atom(buf: StringBuffer, result: TokenBuffer): Boolean
  function ic:tokenize_atom(buf, result)
    local pos = buf:tell()
    local atom, len = buf:scan_raw("^[%a_][_%a%d]*")
    if atom then
      result:push_token("atom", atom, { pos = pos, len = len })
      return true
    end
    return false
  end

  --- Example:
  ---   .org
  ---   .word
  ---   .something_kinda_long_and_awesome_of_sorts124
  ---
  --- @spec #tokenize_directive(buf: StringBuffer, result: TokenBuffer): Boolean
  function ic:tokenize_directive(buf, result)
    local pos = buf:tell()
    local atom, len = buf:scan_raw("^%.[%a_][_%a%d]*")
    if atom then
      result:push_token("directive", atom, { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_dollar_hex(buf, result)
    local pos = buf:tell()
    local hex, len = buf:scan_raw("^%$[0-9A-Fa-f]+")
    if hex then
      result:push_token("hex", string.sub(hex, 2), { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_integer(buf, result)
    local pos = buf:tell()
    local int, len = buf:scan_raw("^%d+")
    if int then
      result:push_token("integer", tonumber(int), { pos = pos, len = len })
      return true
    end
    return false
  end

  function ic:tokenize_value(buf, result)
    if self:tokenize_atom(buf, result) then
      return true
    end
    if self:tokenize_dollar_hex(buf, result) then
      return true
    end
    if self:tokenize_integer(buf, result) then
      return true
    end
    return false
  end

  --- @spec #tokenize(String): (TokenBuffer, rest: String)
  function ic:tokenize(str)
    local buf = StringBuffer:new(str, "r")

    local result = TokenBuffer:new({}, "w")
    local next_char

    while not buf:isEOF() do
      next_char = buf:peek_byte(1)

      if next_char == SC then
        self:tokenize_comment(buf, result)
      elseif next_char == CM then
        self:tokenize_comma(buf, result)
      elseif next_char == CO then
        self:tokenize_colon(buf, result)
      elseif next_char == HASH then
        self:tokenize_hash(buf, result)
      elseif next_char == ORBL then
        self:tokenize_open_round_bracket(buf, result)
      elseif next_char == ORBR then
        self:tokenize_close_round_bracket(buf, result)
      elseif next_char == CR or next_char == LF then
        self:tokenize_newlines(buf, result)
      elseif next_char == DQUOTE then
        self:tokenize_dquote(buf, result)
      elseif next_char == SQUOTE then
        self:tokenize_squote(buf, result)
      elseif next_char == SPACE or next_char == TAB then
        self:tokenize_spaces(buf, result)
      elseif next_char == DOT then
        self:tokenize_directive(buf, result)
      else
        if not self:tokenize_value(buf, result) then
          break
        end
      end
    end

    return result, buf:read()
  end
end

yatm_oku.OKU.isa.MOS6502.Lexer = Lexer
