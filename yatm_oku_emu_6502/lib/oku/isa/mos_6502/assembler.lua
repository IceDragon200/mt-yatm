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
local TokenBuffer = assert(yatm_oku.TokenBuffer)
local NMOS_Assembly = assert(yatm_oku.OKU.isa.MOS6502.NMOS_Assembly)
local AssemblyBuilder = assert(yatm_oku.OKU.isa.MOS6502.Builder)

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

--- @spec assemble_tokens(TokenBuffer): (blob: String, AssemblerContext)
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

--- @spec assemble(blob: String): (binary: String, context: AssemblerContext, error: String)
function m.assemble(blob)
  local tokens, rest = m.parse(blob)

  local blob, context = m.assemble_tokens(tokens)
  return blob, context, rest
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
