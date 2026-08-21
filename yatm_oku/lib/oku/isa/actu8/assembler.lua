local bit = assert(foundation.com.bit)
local floor = assert(math.floor)
local ACTU8 = assert(yatm_oku.OKU.isa.ACTU8)
local Builder = assert(ACTU8.Builder)

--- @namespace yatm_oku.OKU.isa.ACTU8.Assembler
local AssemblyError = foundation.com.Class:extends("yatm_oku.OKU.isa.ACTU8.AssemblyError")
ACTU8.AssemblyError = AssemblyError
do
  local ic = AssemblyError.instance_class

  --- @override
  --- @spec #initialize(message: String, line?: Number): void
  function ic:initialize(message, line)
    ic._super.initialize(self)
    self.message = message
    self.line = line or false
  end

  --- @override
  --- @spec to_string(): String
  function ic:to_string()
    if self.line then
      return string.format("ACTU8 Assembly Error @ %d: %s", self.line, self.message)
    else
      return string.format("ACTU8 Assembly Error: %s", self.message)
    end
  end
end

local Assembler = {}

local INSTRUCTIONS = {
  nop =     { size = 1 },
  halt =    { size = 1 },
  push =    { size = 1 },
  pop =     { size = 1 },
  clz =     { size = 1 },
  clc =     { size = 1 },
  clb =     { size = 1 },
  cli =     { size = 1 },
  ret =     { size = 1 },
  ldi =     { size = 2, operand = "u8" },
  lda =     { size = 2, operand = "ram" },
  sta =     { size = 2, operand = "ram" },
  add =     { size = 2, operand = "ram" },
  sub =     { size = 2, operand = "ram" },
  cmp =     { size = 2, operand = "ram" },
  ["and"] = { size = 2, operand = "ram" },
  ["or"] =  { size = 2, operand = "ram" },
  ["xor"] = { size = 2, operand = "ram" },
  jmp =     { size = 3, operand = "code" },
  call =    { size = 3, operand = "code" },
  jz =      { size = 3, operand = "code" },
  jnz =     { size = 3, operand = "code" },
  jc =      { size = 3, operand = "code" },
  jnc =     { size = 3, operand = "code" },
  jb =      { size = 3, operand = "code" },
  jnb =     { size = 3, operand = "code" },
  ji =      { size = 3, operand = "code" },
  jni =     { size = 3, operand = "code" },
  ["in"] =  { size = 2, operand = "io" },
  out =     { size = 2, operand = "io" },
}
Assembler.INSTRUCTIONS = INSTRUCTIONS

local function fail(line, message)
  error(AssemblyError:new(message, line), 0)
end

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function tokenize_expression(source, line)
  local i = 0
  local result = {}
  local pos = 1
  local len = #source

  local rest
  local ws
  local token
  while pos <= len do
    rest = source:sub(pos)
    ws = rest:match("^%s+")
    if ws then
      pos = pos + #ws
    else
      token =
        rest:match("^0[xX][%da-fA-F]+")
        or rest:match("^0[bB][01]+")
        or rest:match("^0[oO][0-7]+")
        or rest:match("^%d+")
        or rest:match("^[%a_][%w_]*")
        or rest:match("^<<") or rest:match("^>>")
        or rest:match("^[()+%*/%%&|%^~-]")

      if not token then
        fail(line, "unexpected character '" .. rest:sub(1, 1) .. "' in expression")
      end
      i = i + 1
      result[i] = token
      pos = pos + #token
    end
  end
  return result
end

local function number_value(token)
  local prefix = token:sub(1, 2):lower()
  if prefix == "0x" then
    return tonumber(token:sub(3), 16)
  elseif prefix == "0b" then
    return tonumber(token:sub(3), 2)
  elseif prefix == "0o" then
    return tonumber(token:sub(3), 8)
  end
  return tonumber(token, 10)
end

local PRECEDENCE = {
  ["|"] = 1,
  ["^"] = 2,
  ["&"] = 3,
  ["<<"] = 4,
  [">>"] = 4,
  ["+"] = 5,
  ["-"] = 5,
  ["*"] = 6,
  ["/"] = 6,
  ["%"] = 6
}

local function apply_binary(op, lhs, rhs, line)
  if op == "+" then
    return lhs + rhs
  elseif op == "-" then
    return lhs - rhs
  elseif op == "*" then
    return lhs * rhs
  elseif op == "/" then
    if rhs == 0 then
      fail(line, "division by zero")
    end
    return floor(lhs / rhs)
  elseif op == "%" then
    if rhs == 0 then
      fail(line, "division by zero")
    end
    return lhs % rhs
  elseif op == "<<" then
    return lhs * (2 ^ rhs)
  elseif op == ">>" then
    return floor(lhs / (2 ^ rhs))
  elseif op == "&" then
    return bit.band(lhs, rhs)
  elseif op == "|" then
    return bit.bor(lhs, rhs)
  elseif op == "^" then
    return bit.bxor(lhs, rhs)
  else
    fail(line, "unexpected operator op=" .. op)
  end
end

local function parse_expression(source, line)
  local tokens = tokenize_expression(source, line)
  local pos = 1
  local function parse(min_precedence)
    local token = tokens[pos]
    if not token then
      fail(line, "expected expression")
    end
    pos = pos + 1
    local node
    if token == "(" then
      node = parse(1)
      if tokens[pos] ~= ")" then
        fail(line, "expected ')'")
      end
      pos = pos + 1
    elseif token == "+" or token == "-" or token == "~" then
      node = { tag = "unary", op = token, value = parse(7) }
    else
      local value = number_value(token)
      if value then
        node = { tag = "number", value = value }
      elseif token:match("^[%a_]") then
        node = { tag = "symbol", name = token }
      else
        fail(line, "expected value, got '" .. token .. "'")
      end
    end
    local op
    local rank
    while true do
      op = tokens[pos]
      rank = PRECEDENCE[op]
      if not rank or rank < min_precedence then
        break
      end
      pos = pos + 1
      node = { tag = "binary", op = op, left = node, right = parse(rank + 1) }
    end
    return node
  end
  local result = parse(1)
  if tokens[pos] then
    fail(line, "unexpected token '" .. tokens[pos] .. "'")
  end
  return result
end

local function split_values(source, line)
  local vi = 0
  local values = {}
  local depth = 0
  local start = 1
  local len = #source

  local char
  for i = 1,len do
    char = source:sub(i, i)
    if char == "(" then
      depth = depth + 1
    elseif char == ")" then
      depth = depth - 1
    elseif char == "," and depth == 0 then
      vi = vi + 1
      values[vi] = parse_expression(trim(source:sub(start, i - 1)), line)
      start = i + 1
    end

    if depth < 0 then
      fail(line, "unexpected ')'")
    end
  end
  if depth ~= 0 then
    fail(line, "unclosed '('")
  end
  vi = vi + 1
  values[vi] = parse_expression(trim(source:sub(start)), line)
  return values
end

local function parse(source)
  if type(source) ~= "string" then error("expected assembly source string", 2) end
  local statements = {}
  local line_number = 0
  source = source .. "\n"
  for raw_line in source:gmatch("([^\r\n]*)\r?\n") do
    line_number = line_number + 1
    local line = trim(raw_line:gsub("%s*[;].*$", ""):gsub("^%s*//.*$", ""):gsub("%s+//.*$", ""))
    if line ~= "" then
      local label, rest = line:match("^([%a_][%w_]*):%s*(.*)$")
      if label then
        statements[#statements + 1] = { tag = "label", name = label, line = line_number }
        line = rest
      end
      if line ~= "" then
        local command, args = line:match("^%.?([%a_][%w_]*)%s*(.*)$")
        if not command then fail(line_number, "cannot parse statement") end
        command = command:lower()
        if command == "section" then
          local section = trim(args):lower()
          if section ~= "code" and section ~= "ram" and section ~= "io" then
            fail(line_number, "unknown section '" .. section .. "'")
          end
          statements[#statements + 1] = { tag = "section", section = section, line = line_number }
        elseif command == "const" then
          local name, expression = args:match("^([%a_][%w_]*)%s*=%s*(.+)$")
          if not name then fail(line_number, "expected 'const name = expression'") end
          statements[#statements + 1] = { tag = "const", name = name,
            expression = parse_expression(expression, line_number), line = line_number }
        elseif command == "origin" or command == "org" then
          statements[#statements + 1] = { tag = "origin",
            expression = parse_expression(args, line_number), line = line_number }
        elseif command == "byte" or command == "word" then
          statements[#statements + 1] = { tag = command,
            values = split_values(args, line_number), line = line_number }
        else
          local descriptor = INSTRUCTIONS[command]
          if not descriptor then fail(line_number, "unknown instruction '" .. command .. "'") end
          local expression
          if descriptor.operand then
            if args == "" then fail(line_number, command .. " expects an operand") end
            expression = parse_expression(args, line_number)
          elseif args ~= "" then
            fail(line_number, command .. " does not take an operand")
          end
          statements[#statements + 1] = { tag = "instruction", name = command,
            descriptor = descriptor, expression = expression, line = line_number }
        end
      end
    end
  end
  return statements
end
Assembler.parse = parse

local function evaluate(node, symbols, line, resolving)
  if node.tag == "number" then
    return node.value, nil
  elseif node.tag == "symbol" then
    local symbol = symbols[node.name]
    if not symbol then
      fail(line, "undefined symbol '" .. node.name .. "'")
    end
    if symbol.value == nil then
      if resolving[node.name] then
        fail(line, "cyclic constant '" .. node.name .. "'")
      end
      resolving[node.name] = true
      symbol.value, symbol.kind = evaluate(symbol.expression, symbols, symbol.line, resolving)
      resolving[node.name] = nil
    end
    return symbol.value, symbol.kind
  end
  local value, kind
  if node.tag == "unary" then
    value, kind = evaluate(node.value, symbols, line, resolving)
    if kind then fail(line, "cannot apply unary operator to a " .. kind .. " address") end
    if node.op == "-" then return -value, nil end
    if node.op == "~" then return -value - 1, nil end
    return value, nil
  end
  local lhs, lhs_kind = evaluate(node.left, symbols, line, resolving)
  local rhs, rhs_kind = evaluate(node.right, symbols, line, resolving)

  if lhs_kind and rhs_kind then
    if node.op == "-" and lhs_kind == rhs_kind then
      return apply_binary(node.op, lhs, rhs, line), nil
    end
    fail(line, "cannot combine " .. lhs_kind .. " and " .. rhs_kind .. " addresses")
  elseif rhs_kind and node.op == "-" then
    fail(line, "cannot subtract a typed address from an untyped value")
  elseif (lhs_kind or rhs_kind) and node.op ~= "+" and node.op ~= "-" then
    fail(line, "only + and - are valid on typed addresses")
  end

  return apply_binary(node.op, lhs, rhs, line), lhs_kind or rhs_kind
end

local function write_at(section, position, blob, line)
  if position < 0 then fail(line, "origin cannot be negative") end
  local last = position + #blob
  if section.name ~= "code" and last > 256 then
    fail(line, section.name .. " section exceeds 256 bytes")
  end
  for i = 1, #blob do
    local index = position + i
    if section.bytes[index] ~= nil then fail(line, "output overlaps previously emitted data") end
    section.bytes[index] = blob:byte(i)
  end
  section.pos = last
  if last > section.size then section.size = last end
end

local function section_blob(section)
  local result = {}
  for index = 1, section.size do result[index] = string.char(section.bytes[index] or 0) end
  return table.concat(result)
end

function Assembler.assemble(source)
  local statements = parse(source)
  local sections = {
    code = { name = "code", pos = 0, size = 0, bytes = {} },
    ram = { name = "ram", pos = 0, size = 0, bytes = {} },
    io = { name = "io", pos = 0, size = 0, bytes = {} },
  }
  local symbols, current = {}, "code"
  local function define(name, symbol, line)
    if symbols[name] then fail(line, "duplicate symbol '" .. name .. "'") end
    symbols[name] = symbol
  end

  -- Constants do not occupy space, so collect them before layout. This permits
  -- forward constants in origins without making labels depend on source order.
  for _, statement in ipairs(statements) do
    if statement.tag == "const" then
      define(statement.name, {
        expression = statement.expression,
        line = statement.line,
      }, statement.line)
    end
  end

  -- Pass one assigns section-relative labels and computes all instruction sizes.
  for _, statement in ipairs(statements) do
    if statement.tag == "section" then current = statement.section
    elseif statement.tag == "label" then
      define(statement.name, { value = sections[current].pos, kind = current,
        line = statement.line }, statement.line)
    elseif statement.tag == "const" then
      -- Constants were collected before layout.
    elseif statement.tag == "origin" then
      local value, kind = evaluate(statement.expression, symbols, statement.line, {})
      if kind then fail(statement.line, "origin must be an untyped value") end
      if value < sections[current].pos then fail(statement.line, "origin moves backwards") end
      sections[current].pos = value
      if value > sections[current].size then sections[current].size = value end
    elseif statement.tag == "instruction" then
      if current ~= "code" then fail(statement.line, "instructions belong in the code section") end
      sections.code.pos = sections.code.pos + statement.descriptor.size
      if sections.code.pos > sections.code.size then sections.code.size = sections.code.pos end
    elseif statement.tag == "byte" then
      sections[current].pos = sections[current].pos + #statement.values
      if sections[current].pos > sections[current].size then sections[current].size = sections[current].pos end
    elseif statement.tag == "word" then
      sections[current].pos = sections[current].pos + #statement.values * 2
      if sections[current].pos > sections[current].size then sections[current].size = sections[current].pos end
    end
  end

  for _, section in pairs(sections) do section.pos, section.size, section.bytes = 0, 0, {} end
  current = "code"
  for _, statement in ipairs(statements) do
    local section = sections[current]
    if statement.tag == "section" then current = statement.section
    elseif statement.tag == "origin" then
      section = sections[current]
      section.pos = evaluate(statement.expression, symbols, statement.line, {})
      if section.pos > section.size then section.size = section.pos end
    elseif statement.tag == "instruction" then
      section = sections.code
      local blob
      if statement.expression then
        local value, kind = evaluate(statement.expression, symbols, statement.line, {})
        local expected = statement.descriptor.operand
        if kind and kind ~= expected then
          fail(statement.line, statement.name .. " expects a " .. expected ..
            " address, got " .. kind)
        end
        local maximum = expected == "code" and 0xFFFF or 0xFF
        if value % 1 ~= 0 or value < 0 or value > maximum then
          fail(statement.line, statement.name .. " operand is outside 0.." .. maximum)
        end
        blob = Builder[statement.name](value)
      else
        blob = Builder[statement.name]()
      end
      write_at(section, section.pos, blob, statement.line)
    elseif statement.tag == "byte" or statement.tag == "word" then
      section = sections[current]
      for _, expression in ipairs(statement.values) do
        local value, kind = evaluate(expression, symbols, statement.line, {})
        if kind then fail(statement.line, statement.tag .. " expects an untyped value") end
        local maximum = statement.tag == "byte" and 0xFF or 0xFFFF
        if value % 1 ~= 0 or value < 0 or value > maximum then
          fail(statement.line, statement.tag .. " value is outside 0.." .. maximum)
        end
        local blob
        if statement.tag == "byte" then blob = string.char(value)
        else blob = string.char(value % 256, math.floor(value / 256)) end
        write_at(section, section.pos, blob, statement.line)
      end
    end
  end

  local context = { symbols = symbols, sections = {
    code = section_blob(sections.code), ram = section_blob(sections.ram),
    io = section_blob(sections.io),
  } }
  return context.sections.code, context
end

function Assembler.assemble_safe(source)
  local result, binary, context = pcall(Assembler.assemble, source)
  if result then return true, binary, context end
  return false, binary, nil
end

ACTU8.Assembler = Assembler
