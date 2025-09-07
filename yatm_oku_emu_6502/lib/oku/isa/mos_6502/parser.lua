local TokenBuffer = assert(yatm_oku.TokenBuffer)
local match_tokens = assert(yatm_oku.match_tokens)
local string_pad_leading = assert(foundation.com.string_pad_leading)
local string_rsub = assert(foundation.com.string_rsub)
local string_hex_pair_to_byte = assert(foundation.com.string_hex_pair_to_byte)

--- @namespace yatm_oku.OKU.isa.MOS6502.Parser
local Parser = foundation.com.Class:extends("yatm_oku.OKU.isa.MOS6502.Parser")
do
  local ic = Parser.instance_class

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    self.m_constants = {}
    self.m_reserved = {
      x = true,
      X = true,
      y = true,
      Y = true,
    }
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

  function ic:parse_comment(input, _output)
    if input:scan("ws", "comment", "nl") then
      return true
    elseif input:scan("comment", "nl") then
      return true
    elseif input:scan("ws", "comment") then
      return true
    elseif input:skip("comment") then
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

  --- @spec parse_register_name(input: TokenBuffer): Any | nil
  function ic:parse_register_name(input)
    local pos = input:tell()
    local token = input:scan_one("atom")
    if token then
      local name = token_value(token)

      if name == "X" or name == "x" then
        return {"register_x", true, token_debug(token)}
      elseif name == "Y" or name == "y" then
        return {"register_y", true, token_debug(token)}
      end
    end

    -- abort
    input:seek(pos)
    return nil
  end

  --- @private.spec hex_token_to_byte(token: Token): Integer
  local function hex_token_to_byte(token)
    local hex_value = token_value(token)
    if #hex_value < 2 then
      -- TODO: issue warning, the value was padded
      hex_value = string_pad_leading(hex_value, 2, "0")
    elseif #hex_value > 2 then
      -- TODO: issue warning, the value was truncated
      hex_value = string_rsub(hex_value, 2)
    end
    return string_hex_pair_to_byte(hex_value)
  end

  --- @private.spec hex_token_to_num(token: Token): Integer
  local function hex_token_to_num(token)
    local hex_value = token_value(token)
    if #hex_value > 2 then
      hex_value = string_pad_leading(hex_value, 4, "0")
      hex_value = string_rsub(hex_value, 4)
      local hipair = string.sub(hex_value, 1, 2)
      local lopair = string.sub(hex_value, 3, 4)
      return hipair * 256 + lopair
    end

    return self:hex_token_to_byte(token)
  end

  --- @spec #parse_absolute_or_zeropage_address(TokenBuffer): Token | nil
  function ic:parse_absolute_or_zeropage_address(input)
    local pos = input:tell()
    local token =
      input:scan_one("integer")
      or input:scan_one("hex")
      or input:scan_one("atom")

    if token then
      local name = token_name(token)
      if name == "atom" then
        -- try to resolve constant
        local constant_name = token_value(token)
        local const_buffer = self.m_constants[constant_name]
        if not const_buffer then
          return nil
        end
        const_buffer:reopen("r")
        local value = self:parse_absolute_or_zeropage_address(const_buffer)
        if value then
          return value
        else
          input:seek(pos)
          return nil
        end
      end

      local debug_info = token_debug(token)
      if name == "hex" then
        local hex_value = token_value(token)
        if #hex_value <= 2 then
          hex_value = string_pad_leading(hex_value, 2, "0")
          local value = string_hex_pair_to_byte(hex_value)
          return {"zeropage", value, debug_info}
        else
          hex_value = string_pad_leading(hex_value, 4, "0")
          hex_value = string_rsub(hex_value, 4)
          local hipair = string.sub(hex_value, 1, 2)
          local lopair = string.sub(hex_value, 3, 4)
          return {"absolute", hipair * 256 + lopair, debug_info}
        end
      else
        local value = token_value(token)
        if value > 255 then
          return {"absolute", value, debug_info}
        else
          return {"zeropage", value, debug_info}
        end
      end
    end
    return nil
  end

  --- @spec #parse_number(TokenBuffer): Integer | nil
  function ic:parse_number(input)
    local pos = input:tell()
    local token =
      input:scan_one("hex")
      or input:scan_one("integer")
      or input:scan_one("atom")

    if token then
      if token_name(token) == "atom" then
        -- try to resolve constant
        local constant_name = token_value(token)
        local const_buffer = self.m_constants[constant_name]
        if not const_buffer then
          return nil
        end
        const_buffer:reopen("r")
        local value = self:parse_number(const_buffer)
        if value then
          return value
        else
          input:seek(pos)
          return nil
        end
      end

      local value
      if token[1] == "hex" then
        value = hex_token_to_byte(token)
      elseif token[1] == "integer" then
        value = math.min(math.max(-128, token[2]), 255)
      else
        error("expected an integer or hex")
      end
      return value
    end
    return nil
  end

  --- @spec #parse_value(TokenBuffer): Integer | String | nil
  function ic:parse_value(input)
    local pos = input:tell()
    local token =
      input:scan_one("dquote")
      or input:scan_one("squote")
      or input:scan_one("hex")
      or input:scan_one("integer")
      or input:scan_one("atom")

    if token then
      local name = token_name(token)
      if token_name == "atom" then
        -- try to resolve constant
        local constant_name = token_value(token)
        local debug_info = token_debug(token)
        local const_buffer = self.m_constants[constant_name]
        if not const_buffer then
          error("unresolved constant reference"
            .. " name=" .. constant_name
            .. " pos=" .. debug_info.pos
          )
        end
        const_buffer:reopen("r")
        local value = self:parse_value(const_buffer)
        if value then
          return value
        else
          input:seek(pos)
          return nil
        end
      end

      local value
      if name == "hex" then
        value = hex_token_to_byte(token)
      elseif name == "integer" then
        value = math.min(math.max(-128, token_value(token)), 255)
      elseif name == squote or name == dquote then
        value = token_value(token)
      else
        error("expected an integer, hex, dquote or squote")
      end
      return value
    end
    return nil
  end

  --- @spec #parse_immediate_value(TokenBuffer): Token
  function ic:parse_immediate_value(input)
    local pos = input:tell()
    local token =
      input:scan_one("hex")
      or input:scan_one("integer")
      or input:scan_one("atom")

    if token then
      local name = token_name(token)
      if name == "atom" then
        -- try to resolve constant
        local constant_name = token_value(token)
        local debug_info = token_debug(token)
        local const_buffer = self.m_constants[constant_name]
        if not const_buffer then
          error("unresolved constant reference"
            .. " name=" .. constant_name
            .. " pos=" .. debug_info.pos
          )
        end
        const_buffer:reopen("r")
        local value = self:parse_immediate_value(const_buffer)
        if value then
          return value
        else
          input:seek(pos)
          return nil
        end
      end

      local value
      if name == "hex" then
        value = hex_token_to_byte(token)
      elseif name == "integer" then
        value = math.min(math.max(-128, token_value(token)), 255)
      else
        error("expected an integer or hex")
      end
      return {"immediate", value, token_debug(token)}
    end
    return nil
  end

  --- @spec #parse_immediate(input: TokenBuffer): Token
  function ic:parse_immediate(input)
    local pos = input:tell()
    local token = input:scan_one("#")
    if token then
      local result = self:parse_immediate_value(input)
      if result then
        return result
      else
        -- abort
        input:seek(pos)
      end
    end
    return nil
  end

  --- @spec #parse_indirect_offset(TokenBuffer): Token | nil
  function ic:parse_indirect_offset(input)
    local pos = input:tell()
    if input:skip("(") then
      local result = {}
      local i = 0
      local token
      while not input:isEOB() do
        input:skip("ws") -- skip leading spaces
        token = input:scan_one("hex") or
                input:scan_one("integer") or
                self:parse_register_name(input) or
                input:scan_one("atom")

        if token_name(token) == "atom" then
          local constant_name = token_value(token)
          local constant_buffer = self.m_constants[constant_name]
          if constant_buffer then
            constant_buffer:reopen("r")
            token =
              constant_buffer:scan_one("hex")
              or constant_buffer:scan_one("integer")
              or self:parse_register_name(constant_buffer)
          else
            error("unresolved constant name=" .. constant_name)
          end
        end

        if token then
          i = i + 1
          result[i] = token
          input:skip("ws")
          if input:skip(",") then
            -- can continue
          else
            break
          end
        else
          break
        end
      end

      input:skip("ws") -- skip trailing spaces

      if input:skip(")") then
        local argc = #result
        if argc == 2 then
          if match_tokens(result, 1, 2, {"hex", "register_x"}) then
            local debug_info = token_debug(result[1])
            return {"indirect_x", hex_token_to_byte(result[1]), debug_info}
          elseif match_tokens(result, 1, 2, {"integer", "register_x"}) then
            local debug_info = token_debug(result[1])
            return {"indirect_x", token_value(result[1]), debug_info}
          else
            error("unexpected indirect args")
          end
        elseif argc == 1 then
          local debug_info = token_debug(result[1])
          if match_tokens(result, 1, 1, {"hex"}) then
            return {"indirect", hex_token_to_num(result[1]), debug_info}
          elseif match_tokens(result, 1, 1, {"integer"}) then
            return {"indirect", token_value(result[1]), debug_info}
          else
            error("unexpected token")
          end
        else
          error("invalid number of arguments expected 1 or 2 (got " .. argc .. ")")
        end
      else
        error("invalid indirect syntax, expected (hex | integer[,X|Y])")
      end
    end

    input:seek(pos)
    return nil
  end

  --- @spec #parse_ins_arg(input: TokenBuffer): Token
  function ic:parse_ins_arg(input)
    return self:parse_register_name(input) or
           self:parse_absolute_or_zeropage_address(input) or
           self:parse_immediate(input) or
           self:parse_indirect_offset(input)
  end

  local function tokens_to_addressing_mode(result)
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
        error("invalid 1 argument pattern (got " .. token_name(result[1]) .. ")")
      end
    elseif argc == 2 then
      if match_tokens(result, 1, 2, {"absolute", "register_x"}) then
        return {{"absolute_x", result[1][2], result[1][3]}}
      elseif match_tokens(result, 1, 2, {"absolute", "register_y"}) then
        return {{"absolute_y", result[1][2], result[1][3]}}
      elseif match_tokens(result, 1, 2, {"indirect", "register_y"}) then
        return {{"indirect_y", result[1][2], result[1][3]}}
      elseif match_tokens(result, 1, 2, {"zeropage", "register_y"}) then
        return {{"zeropage_y", result[1][2], result[1][3]}}
      elseif match_tokens(result, 1, 2, {"zeropage", "register_x"}) then
        return {{"zeropage_x", result[1][2], result[1][3]}}
      else
        error("invalid 2 argument pattern")
      end
    else
      error("invalid number of arguments expected 0, 1 or 2 got " .. #result)
    end
  end

  function ic:parse_ins_args(input)
    local result = {}
    local i = 0
    local token
    while not input:isEOB() do
      input:skip("ws")
      token = self:parse_ins_arg(input)
      if token then
        i = i + 1
        result[i] = token
        input:skip("ws")
        if not input:skip(",") then
          -- there are no more args
          break
        end
      else
        -- there are no more tokens
        break
      end
    end

    return tokens_to_addressing_mode(result)
  end

  --- @spec #parse_ins(input: TokenBuffer, output: TokenBuffer): Boolean
  function ic:parse_ins(input, output)
    local ins = input:scan_one("atom")
    if ins then
      local args = self:parse_ins_args(input)
      self:parse_line_term(input, output)
      output:push_token("ins", {
        name = string.lower(token_value(ins)),
        args = args
      }, token_debug(ins))
      return true
    end
    return false
  end

  --- @spec #parse_directive(input: TokenBuffer, output: TokenBuffer): Boolean
  function ic:parse_directive(input, output)
    local token = input:scan_one("directive")
    if token then
      local directive = token_value(token)
      directive = string.upper(directive)
      if directive == ".ORG" then
        input:skip("ws") -- skip trailing spaces
        local value = self:parse_number(input)
        output:push_token("set_origin", value, token_debug(token))
        return true
      elseif directive == ".BYTE" then
        input:skip("ws") -- skip trailing spaces
        local value = self:parse_value(input)
        output:push_token("emit_byte", value, token_debug(token))
        return true
      elseif directive == ".WORD" then
        input:skip("ws") -- skip trailing spaces
        local value = self:parse_value(input)
        output:push_token("emit_word", value, token_debug(token))
        return true
      elseif directive == ".CONST" then
        input:skip("ws") -- skip trailing spaces
        local name_token = input:scan_one("atom")
        if name_token then
          local name = token_value(name_token)
          assert(name, "expected a constant name")
          input:skip("ws") -- skip trailing spaces
          local tokens = input:scan_upto("nl") or input:rest()
          if self.m_reserved[name] then
            error("reserved atom name=" .. name)
          end
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

  --- @spec #parse_next(input: TokenBuffer, output: TokenBuffer): Boolean
  function ic:parse_next(input, output)
    if self:parse_line_term(input, output) then
      return true
    elseif self:parse_label(input, output) then
      return true
    elseif self:parse_directive(input, output) then
      return true
    elseif self:parse_ins(input, output) then
      return true
    else
      return false
    end
  end

  --- @spec parse(input: TokenBuffer): TokenBuffer
  function ic:parse(input)
    local output = TokenBuffer:new({}, 'w')

    while not input:isEOB() do
      input:skip("ws")
      if not self:parse_next(input, output) then
        error("could not complete parsing, next token is " .. dump(input:peek_token()))
      end
    end
    return output
  end
end

yatm_oku.OKU.isa.MOS6502.Parser = Parser
