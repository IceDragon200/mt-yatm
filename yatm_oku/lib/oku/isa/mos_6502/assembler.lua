--
-- Below is a set of modules for assembling 6502 assembly into its binary form
-- This can then be executed by the OKU 6502.
-- This comes with a full lexer as well, so you could theorectically use
-- it for other stuff.
--
local Lexer = assert(yatm_oku.OKU.isa.MOS6502.Lexer)
local Parser = assert(yatm_oku.OKU.isa.MOS6502.Parser)

yatm_oku:require("lib/oku/isa/mos_6502/nmos_assembly.lua")

local NMOS_Assembly = assert(yatm_oku.OKU.isa.MOS6502.NMOS_Assembly)
local AssemblyBuilder = assert(yatm_oku.OKU.isa.MOS6502.Builder)
local Assembler = {
  Lexer = Lexer,
  Parser = Parser,
}

local m = Assembler

function m.parse(prog)
  local token_buf, rest = m.Lexer.tokenize(prog)
  token_buf:open('r')
  return m.Parser.parse(token_buf), rest
end

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

-- @spec assemble(String): (binary: String, error: String)
function m.assemble(prog)
  local tokens, rest = m.parse(prog)

  local blob, context = m.assemble_tokens(tokens)
  return blob, context, rest
end

-- @spec assemble_safe(String): (Boolean, binary: String, error: String)
function m.assemble_safe(prog)
  local result, blob, context, rest =
    pcall(function ()
      return m.assemble(prog)
    end)

  if result then
    return true, blob, context, rest
  else
    return false, blob
  end
end

yatm_oku.OKU.isa.MOS6502.Assembler = Assembler
