--
-- Below is a set of modules for assembling 6502 assembly into its binary form
-- This can then be executed by the OKU 6502.
-- This comes with a full lexer as well, so you could theorectically use
-- it for other stuff.
--
yatm_oku_emu_6502:require("lib/oku/isa/mos_6502/nmos_assembly.lua")

local Lexer = assert(yatm_oku.OKU.isa.MOS6502.Lexer)
local Parser = assert(yatm_oku.OKU.isa.MOS6502.Parser)
local Class = assert(foundation.com.Class)
local StringBuffer = assert(foundation.com.StringBuffer)
local TokenBuffer = assert(yatm_oku.TokenBuffer)
local NMOS_Assembly = assert(yatm_oku.OKU.isa.MOS6502.NMOS_Assembly)
local AssemblyBuilder = assert(yatm_oku.OKU.isa.MOS6502.Builder)
local ByteEncoder = assert(foundation.com.ByteEncoder)
local BELE = assert(ByteEncoder.LE)

--- @namespace yatm_oku.OKU.isa.MOS6502.Assembler

--- @type AssemblerContext: {
---   pos: Integer,
---   jump_table: {
---     [label: String]: Integer
---   }
--- }

local lexer = Lexer:new()

local Assembler = {
  lexer = lexer,
}

local m = Assembler

--- @spec parse(String | TokenBuffer): (TokenBuffer, rest: String | nil)
function m.parse(prog)
  local token_buf
  local rest
  if type(prog) == "string" then
    token_buf, rest = m.lexer:tokenize(prog)
    token_buf:reopen("r")
  elseif Class.is_object(prog, TokenBuffer) then
    token_buf = prog
  else
    error("expected a string or TokenBuffer")
  end
  local parser = Parser:new()
  return parser:parse(token_buf), rest
end

--- @spec assemble_tokens(input: TokenBuffer): (blob: String, AssemblerContext)
function m.assemble_tokens(input)
  local tokens = input:to_list()

  local context = {
    -- yes, a zero index
    pos = 0,
    -- TODO: actually use the jump table
    jump_table = {},
  }

  local output = StringBuffer:new("", "w")

  local name
  local value
  local binary
  local leaf
  local arg
  local branch
  local ins_name
  local ins_args
  local size
  for _, token in ipairs(tokens) do
    name = token_name(token)
    value = token_value(token)
    if name == "set_origin" then
      size = output:size()
      if size < value then
        output:seek(size)
        output:fill_bytes(value - size, 0)
      end
      output:seek(value + 1)
    elseif name == "emit_byte" then
      output:write(BELE:e_u8(value))
    elseif name == "emit_word" then
      output:write(BELE:e_u16(value))
    elseif name == "ins" then
      ins_name = value.name
      ins_args = value.args

      branch = NMOS_Assembly[ins_name]
      if branch then
        if #ins_args == 0 then
          leaf = branch["implied"]
          if leaf then
            binary = AssemblyBuilder[leaf]()
            output:write(binary)
          else
            error("invalid instruction " .. ins_name .. " with arg pattern " .. arg[1])
          end
        else
          arg = assert(ins_args[1])
          leaf = branch[arg[1]]
          if leaf then
            binary = AssemblyBuilder[leaf](arg[2])
            output:write(binary)
          else
            error("invalid instruction " .. ins_name .. " with arg pattern " .. arg[1])
          end
        end
      else
        error("no such instruction " .. ins_name)
      end
    elseif name == "label" then
      context.jump_table[value] = context.pos
    else
      error("unexpected token " .. token_name)
    end
  end

  return table.concat(result), context
end

--- @spec assemble(blob: String): (binary: String, context: AssemblerContext, error: String)
function m.assemble(blob)
  local tokens
  local rest

  if type(blob) == "string" then
    tokens, rest = m.parse(blob)
  elseif Class.is_object(prog, TokenBuffer) then
    tokens = blob
  end

  local binary, context = m.assemble_tokens(tokens)
  return binary, context, rest
end

--- @spec assemble_safe(String): (Boolean, binary: String, context: AssemblerContext, rest: String)
function m.assemble_safe(blob)
  local result, binary, context, rest =
    pcall(function ()
      return m.assemble(blob)
    end)

  if result then
    return true, binary, context, rest
  else
    return false, binary, nil, nil
  end
end

yatm_oku.OKU.isa.MOS6502.Assembler = Assembler
