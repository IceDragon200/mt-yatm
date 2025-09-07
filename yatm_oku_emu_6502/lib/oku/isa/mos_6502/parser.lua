local TokenBuffer = assert(yatm_oku.TokenBuffer)
local match_tokens = assert(yatm_oku.match_tokens)
local string_pad_leading = assert(foundation.com.string_pad_leading)
local string_rsub = assert(foundation.com.string_rsub)
local string_hex_pair_to_byte = assert(foundation.com.string_hex_pair_to_byte)

--- @namespace yatm_oku.OKU.isa.MOS6502.Parser
local Parser = foundation.com.Class:extends("yatm_oku.OKU.isa.MOS6502.Parser")
do
  local ic = Parser.instance_class

  function ic:initialize()
    ic._super.initialize(self)

    self.m_constants = {}
  end

  local function token_name(token)
    return token[1]
  end

  local function token_value(token)
    return token[2]
  end

  local function token_debug(token)
    return token[3]
  end

  function ic:parse_comment(token_buf, result)
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

  --- Attempts to parse a label from the input TokenBuffer.
  --- Example:
  ---   main:
  ---
  --- @spec #parse_label(input: TokenBuffer, output: TokenBuffer): Boolean
  function ic:parse_label(input, output)
    local tokens = input:scan("atom", ":")
    if tokens then
      local token = tokens[1]
      output:push_token("label", token_value(token), token_debug(token))
      return true
    end
    return false
  end

  --- Line terms are anything that can be safely skipped over if its on a line by itself.
  --- Effectively any line with whitespace or just comments and terminated by a newline is
  --- applicable.
  --- Example:
  ---   (<space>) (<comment>) <nl>
  ---
  --- @spec #parse_line_term(input: TokenBuffer, output: TokenBuffer): Boolean
  function ic:parse_line_term(input, _output)
    if input:scan("ws", "nl") then
      return true
    elseif input:scan("nl") then
      return true
    elseif input:scan("ws", "comment", "nl") then
      return true
    elseif input:scan("comment", "nl") then
      return true
    end
    return false
  end

  --- @spec parse_register_name_or_atom(input: TokenBuffer): Any | nil
  function ic:parse_register_name_or_atom(input)
    local token = input:scan_one("atom")
    if token then
      local name = token_value(token)

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

  function ic:hex_token_to_byte(token)
    local hex_value = token[2]
    if #hex_value < 2 then
      -- TODO: issue warning, the value was padded
      hex_value = string_pad_leading(hex_value, 2, "0")
    elseif #hex_value > 2 then
      -- TODO: issue warning, the value was truncated
      hex_value = string_rsub(hex_value, 2)
    end
    return string_hex_pair_to_byte(hex_value)
  end

  function ic:hex_token_to_num(token)
    local hex_value = token[2]
    if #hex_value > 2 then
      hex_value = string_pad_leading(hex_value, 4, "0")
      hex_value = string_rsub(hex_value, 4)
      local hipair = string.sub(hex_value, 1, 2)
      local lopair = string.sub(hex_value, 3, 4)
      return hipair * 256 + lopair
    else
      return self:hex_token_to_byte(token)
    end
  end

  function ic:parse_absolute_or_zeropage_address(token_buf)
    local token = token_buf:scan_one("integer") or token_buf:scan_one("hex")

    if token then
      if token[1] == "hex" then
        local hex_value = token[2]
        if #hex_value <= 2 then
          hex_value = string_pad_leading(hex_value, 2, "0")
          local value = string_hex_pair_to_byte(hex_value)
          return {"zeropage", value}
        else
          hex_value = string_pad_leading(hex_value, 4, "0")
          hex_value = string_rsub(hex_value, 4)
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

  function ic:parse_number(token_buf)
    local token =
      token_buf:scan_one("hex")
      or token_buf:scan_one("integer")
      or token_buf:scan_one("atom")

    if token then
      if token[1] == "atom" then
        -- try to resolve constant
        local constant_name = token_value(token)
        local debug_info = token[3]
        local const_buffer = self.m_constants[constant_name]
        if not const_buffer then
          error("unresolved constant reference"
            .. " name=" .. constant_name
            .. " pos=" .. debug_info.pos
          )
        end
        const_buffer:reopen("r")
        return self:parse_number(const_buffer)
      end

      local value
      if token[1] == "hex" then
        value = self:hex_token_to_byte(token)
      elseif token[1] == "integer" then
        value = math.min(math.max(-128, token[2]), 255)
      else
        error("expected an integer or hex")
      end
      return value
    end
    return nil
  end

  function ic:parse_value(token_buf)
    local token =
      token_buf:scan_one("dquote")
      or token_buf:scan_one("squote")
      or token_buf:scan_one("hex")
      or token_buf:scan_one("integer")
      or token_buf:scan_one("atom")

    if token then
      if token[1] == "atom" then
        -- try to resolve constant
        local constant_name = token_value(token)
        local debug_info = token[3]
        local const_buffer = self.m_constants[constant_name]
        if not const_buffer then
          error("unresolved constant reference"
            .. " name=" .. constant_name
            .. " pos=" .. debug_info.pos
          )
        end
        const_buffer:reopen("r")
        return self:parse_value(const_buffer)
      end

      local value
      if token[1] == "hex" then
        value = self:hex_token_to_byte(token)
      elseif token[1] == "integer" then
        value = math.min(math.max(-128, token[2]), 255)
      elseif token[1] == squote or token[1] == dquote then
        value = token[2]
      else
        error("expected an integer, hex, dquote or squote")
      end
      return value
    end
    return nil
  end

  function ic:parse_immediate_value(token_buf)
    local token =
      token_buf:scan_one("hex")
      or token_buf:scan_one("integer")
      or token_buf:scan_one("atom")

    if token then
      if token[1] == "atom" then
        -- try to resolve constant
        local constant_name = token_value(token)
        local debug_info = token[3]
        local const_buffer = self.m_constants[constant_name]
        if not const_buffer then
          error("unresolved constant reference"
            .. " name=" .. constant_name
            .. " pos=" .. debug_info.pos
          )
        end
        const_buffer:reopen("r")
        return self:parse_immediate_value(const_buffer)
      end

      local value
      if token[1] == "hex" then
        value = self:hex_token_to_byte(token)
      elseif token[1] == "integer" then
        value = math.min(math.max(-128, token[2]), 255)
      else
        error("expected an integer or hex")
      end
      return {"immediate", value, token[3]}
    end
    return nil
  end

  function ic:parse_immediate(token_buf)
    local pos = token_buf:tell()
    local token = token_buf:scan_one("#")
    if token then
      local result = self:parse_immediate_value(token_buf)
      if result then
        return result
      else
        token_buf:seek(pos)
      end
    end
    return nil
  end

  function ic:parse_indirect_offset(token_buf)
    if token_buf:skip("(") then
      local result = {}
      while not token_buf:isEOB() do
        token_buf:skip("ws") -- skip leading spaces
        local token = token_buf:scan_one("hex") or
                      token_buf:scan_one("integer") or
                      self:parse_register_name_or_atom(token_buf)
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

  function ic:parse_ins_arg(token_buf)
    local next_token = token_buf:peek_token()
    if next_token and next_token[1] == "atom" then
      local name = next_token[2]
      local const_buffer = self.m_constants[name]
      if const_buffer then
        const_buffer:reopen("r")
        return self:parse_ins_arg(const_buffer)
      end
    end

    return self:parse_register_name_or_atom(token_buf) or
           self:parse_absolute_or_zeropage_address(token_buf) or
           self:parse_immediate(token_buf) or
           self:parse_indirect_offset(token_buf)
  end

  function ic:tokens_to_addressing_mode(result)
    --
    -- TODO: Support variable substitution
    --   Example:
    --     ADC #word
    --     ADC word
    --
    local argc = #result
    if argc == 0 then
      return {}
    elseif argc == 1 then
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
    elseif argc == 2 then
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

  function ic:parse_ins_args(token_buf)
    local result = {}
    local i = 0
    local token
    while not token_buf:isEOB() do
      token_buf:skip("ws")
      token = self:parse_ins_arg(token_buf)
      if token then
        i = i + 1
        result[i] = token
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

    return self:tokens_to_addressing_mode(result)
  end

  function ic:parse_ins(token_buf, result)
    token_buf:skip("ws")
    local ins = token_buf:scan_one("atom")
    if ins then
      local args = self:parse_ins_args(token_buf)
      self:parse_line_term(token_buf, result)
      result:push_token("ins", {
        name = string.lower(token_value(ins)),
        args = args
      }, {})
      return true
    end
    return false
  end

  function ic:parse_directive(token_buf, result)
    local token = token_buf:peek_token()
    if token and token_name(token) == "directive" then
      token_buf:skip("directive")
      local directive = token_value(token)
      directive = string.upper(directive)
      if directive == ".ORG" then
        token_buf:skip("ws") -- skip trailing spaces
        local value = self:parse_number(token_buf)
        result:push_token("set_origin", value, token[3])
        return true
      elseif directive == ".BYTE" then
        token_buf:skip("ws") -- skip trailing spaces
        local value = self:parse_value(token_buf)
        result:push_token("emit_byte", value, token[3])
        return true
      elseif directive == ".WORD" then
        token_buf:skip("ws") -- skip trailing spaces
        local value = self:parse_value(token_buf)
        result:push_token("emit_word", value, token[3])
        return true
      elseif directive == ".CONST" then
        token_buf:skip("ws") -- skip trailing spaces
        local name_token = token_buf:scan_one("atom")
        if name_token then
          local name = token_value(name_token)
          assert(name, "expected a constant name")
          token_buf:skip("ws") -- skip trailing spaces
          local tokens = token_buf:scan_upto("nl") or token_buf:rest()
          if self.m_constants[name] then
            error("constant already assigned name=" .. name)
          end
          self.m_constants[name] = TokenBuffer:new(tokens, "r")
        else
          error("expected a name for constant")
        end
        return true
      else
        error("unexpected directive name=" .. directive)
      end
    end
    return false
  end

  function ic:parse_next(token_buf, result)
    if self:parse_line_term(token_buf, result) then
      return true
    elseif self:parse_label(token_buf, result) then
      return true
    elseif self:parse_directive(token_buf, result) then
      return true
    elseif self:parse_ins(token_buf, result) then
      return true
    else
      return false
    end
  end

  --- @spec parse(Buffer): TokenBuffer
  function ic:parse(token_buf)
    local result = TokenBuffer:new({}, 'w')

    while not token_buf:isEOB() do
      token_buf:skip("ws")
      if not self:parse_next(token_buf, result) then
        error("could not complete parsing, next token is " .. dump(token_buf:peek_token()))
      end
    end
    return result
  end
end

yatm_oku.OKU.isa.MOS6502.Parser = Parser
