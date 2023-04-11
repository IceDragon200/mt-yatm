local TokenBuffer = assert(yatm_oku.TokenBuffer)
local match_tokens = assert(yatm_oku.match_tokens)
local string_pad_leading = assert(foundation.com.string_pad_leading)
local string_rsub = assert(foundation.com.string_rsub)
local string_hex_pair_to_byte = assert(foundation.com.string_hex_pair_to_byte)

--- @namespace yatm_oku.OKU.isa.MOS6502.Parser
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
    hex_value = string_pad_leading(hex_value, 2, "0")
  elseif #hex_value > 2 then
    -- TODO: issue warning, the value was truncated
    hex_value = string_rsub(hex_value, 2)
  end
  return string_hex_pair_to_byte(hex_value)
end

local function hex_token_to_num(token)
  local hex_value = token[2]
  if #hex_value > 2 then
    hex_value = string_pad_leading(hex_value, 4, "0")
    hex_value = string_rsub(hex_value, 4)
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

--- @spec parse(Buffer): TokenBuffer
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

yatm_oku.OKU.isa.MOS6502.Parser = Parser
