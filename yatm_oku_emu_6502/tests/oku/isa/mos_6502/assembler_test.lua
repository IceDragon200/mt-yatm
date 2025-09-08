local string_hex_escape = assert(foundation.com.string_hex_escape)
local Luna = assert(foundation.com.Luna)

do
  local m = yatm_oku.OKU.isa.MOS6502.Assembler

  if not m then
    yatm.warn("OKU.isa.MOS6502.Assembler not available for tests")
    return
  end

  local case = Luna:new("yatm_oku.OKU.isa.MOS6502.Assembler")

  case:describe(".parse/1", function (t2)
    t2:test("can parse an assembly program", function (t3)
      local prog =
        "main:\n" ..
        "  LDA #$00\n" ..
        "  ADC #20\n" ..
        ""

      local tokens, rest = m.parse(prog)

      t3:assert_eq("", rest)

      t3:assert_matches(tokens:to_list(), {
        {"label", "main", {}},
        {"ins", { name = "lda", args = { {"immediate", 0, {}} } }, {}},
        {"ins", { name = "adc", args = { {"immediate", 20, {}} } }, {}},
      })
    end)
  end)

  case:describe(".assemble/1", function (t2)
    t2:test("can assemble a program with directives", function (t3)
      local prog = [[
      .org $0800
      .const VALUE $00
      main:
        lda #VALUE
        adc #20
      ]]

      local object, context, rest = m.assemble(prog)

      t3:assert_eq("", rest)
    end)
  end)

  case:describe(".assemble_safe/1", function (t2)
    t2:test("assembler can safely assemble a 6502 object binary", function (t3)
      local prog =
        "main:\n" ..
        "  LDA #$00\n" ..
        "  ADC #20\n" ..
        ""

      local okay, object, context, rest = m.assemble_safe(prog)

      t3:assert(okay)
      t3:assert_eq("", rest)

      local blob = string_hex_escape(object, "all")
    end)
  end)

  case:execute()
  case:display_stats()
  case:maybe_error()
end
