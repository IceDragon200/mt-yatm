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
    t2:test("test can parse an assembly program", function (t3)
      local prog =
        "main:\n" ..
        "  LDA #$00\n" ..
        "  ADC #20\n" ..
        ""

      local tokens, rest = m.parse(prog)

      t3:assert_eq("", rest)

      t3:assert_deep_eq({
        {"label", "main"},
        {"ins", { name = "lda", args = { {"immediate", 0} } }},
        {"ins", { name = "adc", args = { {"immediate", 20} } }},
      }, tokens:to_list())
    end)
  end)

  case:describe(".assemble_safe/1", function (t2)
    t2:test("assembler can actually assemble a 6502 object binary (without crashing)", function (t3)
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

do
  local m = yatm_oku.OKU.isa.MOS6502.Assembler.Lexer

  if not m then
    yatm.warn("OKU.isa.MOS6502.Assembler.Lexer not available for tests")
    return
  end

  local case = Luna:new("yatm_oku.OKU.isa.MOS6502.Assembler.Lexer")

  case:describe("tokenize/1 (individual tokens)", function (t2)
    t2:test("can tokenize a comment", function (t3)
      local token_buf, rest = m.tokenize("; this is a comment")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("comment"))
    end)

    t2:test("can tokenize comma", function (t3)
      local token_buf, rest = m.tokenize(",")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens(","))
    end)

    t2:test("can tokenize hash", function (t3)
      local token_buf, rest = m.tokenize("#")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("#"))
    end)

    t2:test("can tokenize colon", function (t3)
      local token_buf, rest = m.tokenize(":")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens(":"))
    end)

    t2:test("can tokenize open-round-bracket", function (t3)
      local token_buf, rest = m.tokenize("(")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("("))
    end)

    t2:test("can tokenize closed-round-bracket", function (t3)
      local token_buf, rest = m.tokenize(")")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens(")"))
    end)

    t2:test("can tokenize newlines", function (t3)
      local token_buf, rest = m.tokenize("\n")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("nl"))
    end)

    t2:test("can tokenize single space", function (t3)
      local token_buf, rest = m.tokenize(" ")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("ws"))
    end)

    t2:test("can tokenize single space (as tab)", function (t3)
      local token_buf, rest = m.tokenize("\t")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("ws"))
    end)

    t2:test("can tokenize multiple spaces", function (t3)
      local token_buf, rest = m.tokenize("       ")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("ws"))
    end)

    t2:test("can tokenize multiple spaces (as tabs)", function (t3)
      local token_buf, rest = m.tokenize("\t\t")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("ws"))
    end)

    t2:test("can tokenize single char atom", function (t3)
      local token_buf, rest = m.tokenize("X")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("atom"))
      local tokens = token_buf:scan("atom")
      t3:assert_table_eq({"atom", "X"}, tokens[1])
    end)

    t2:test("can tokenize simple atom word", function (t3)
      local token_buf, rest = m.tokenize("word")
      t3:assert_eq("", rest)
      token_buf:open('r')
      t3:assert(token_buf:match_tokens("atom"))
      local tokens = token_buf:scan("atom")
      t3:assert_table_eq({"atom", "word"}, tokens[1])
    end)

    t2:test("can tokenize complex atoms", function (t3)
      local token_buf, rest = m.tokenize("_marker_with_spaces_and_1234")
      t3:assert_eq("", rest)
      token_buf:open('r')
      local tokens = token_buf:scan("atom")
      t3:assert(tokens[1])
      t3:assert_table_eq({"atom", "_marker_with_spaces_and_1234"}, tokens[1])
    end)

    t2:test("can tokenize all numbers as atoms (leading underscore)", function (t3)
      local token_buf, rest = m.tokenize("_0123456789")
      t3:assert_eq("", rest)
      token_buf:open('r')
      local tokens = token_buf:scan("atom")
      t3:assert(tokens[1])
      t3:assert_table_eq({"atom", "_0123456789"}, tokens[1])
    end)

    t2:test("can tokenize entire latin alphabet atoms", function (t3)
      local token_buf, rest = m.tokenize("the_quick_brown_fox_jumps_over_the_lazy_dog")
      t3:assert_eq("", rest)
      token_buf:open('r')
      local tokens = token_buf:scan("atom")
      t3:assert(tokens[1])
      t3:assert_table_eq({"atom", "the_quick_brown_fox_jumps_over_the_lazy_dog"}, tokens[1])

      local token_buf, rest = m.tokenize("THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG")
      t3:assert_eq("", rest)
      token_buf:open('r')
      local tokens = token_buf:scan("atom")
      t3:assert(tokens[1])
      t3:assert_table_eq({"atom", "THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG"}, tokens[1])
    end)

    t2:test("can tokenize a decimal integer", function (t3)
      local token_buf, rest = m.tokenize("0")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("integer")
      t3:assert(tokens[1])
      t3:assert_table_eq({"integer", 0}, tokens[1])


      local token_buf, rest = m.tokenize("1234567890")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("integer")
      t3:assert(tokens[1])
      t3:assert_table_eq({"integer", 1234567890}, tokens[1])
    end)

    t2:test("can tokenize $hex", function (t3)
      local token_buf, rest = m.tokenize("$00FF")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("hex")
      t3:assert(tokens[1])
      t3:assert_table_eq({"hex", "00FF"}, tokens[1])
    end)

    t2:test("can tokenize entire hex alphabet", function (t3)
      local token_buf, rest = m.tokenize("$0123456789ABCDEFabcdef")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("hex")
      t3:assert(tokens[1])
      t3:assert_table_eq({"hex", "0123456789ABCDEFabcdef"}, tokens[1])
    end)

    t2:test("can tokenize an empty double-quoted string", function (t3)
      local token_buf, rest = m.tokenize("\"\"")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("dquote")
      t3:assert(tokens[1])
      t3:assert_table_eq({"dquote", ""}, tokens[1])
    end)

    t2:test("can tokenize a double-quoted string", function (t3)
      local token_buf, rest = m.tokenize("\"Hello\"")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("dquote")
      t3:assert(tokens[1])
      t3:assert_table_eq({"dquote", "Hello"}, tokens[1])
    end)

    t2:test("can tokenize a complex double-quoted string", function (t3)
      local token_buf, rest = m.tokenize("\"Hello World, how are you m8\"")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("dquote")
      t3:assert(tokens[1])
      t3:assert_table_eq({"dquote", "Hello World, how are you m8"}, tokens[1])
    end)

    t2:test("can tokenize a double-quoted string with escape codes", function (t3)
      local token_buf, rest = m.tokenize("\"New\\nLine\\tTabs\\sSpaces\"")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("dquote")
      t3:assert(tokens[1])
      t3:assert_table_eq({"dquote", "New\nLine\tTabs Spaces"}, tokens[1])
    end)

    t2:test("can tokenize an empty single-quoted string", function (t3)
      local token_buf, rest = m.tokenize("''")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("squote")
      t3:assert(tokens[1])
      t3:assert_table_eq({"squote", ""}, tokens[1])
    end)

    t2:test("can tokenize an a single-quoted string (ignoring escape codes)", function (t3)
      local token_buf, rest = m.tokenize("'\\n\\tHello, World\\s'")
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:scan("squote")
      t3:assert(tokens[1])
      t3:assert_table_eq({"squote", "\\n\\tHello, World\\s"}, tokens[1])
    end)
  end)

  case:describe("tokenize/1 (stream)", function (t2)
    t2:test("can tokenize a simple program", function (t3)
      local prog =
        "main:\n" ..
        "  LDA #0 ; zero accumulator\n" ..
        "  ADC #$20 ; add 32 to the accumulator"

      local token_buf, rest = m.tokenize(prog)
      t3:assert_eq("", rest)
      token_buf:open('r')

      local tokens = token_buf:to_list()

      local result = {
        {"atom", "main"}, {":", true}, {"nl", true},
        {"ws", true}, {"atom", "LDA"}, {"ws", true}, {"#", true}, {"integer", 0}, {"ws", true}, {"comment", " zero accumulator"}, {"nl", true},
        {"ws", true}, {"atom", "ADC"}, {"ws", true}, {"#", true}, {"hex", "20"}, {"ws", true}, {"comment", " add 32 to the accumulator"}
      }
      t3:assert_deep_eq(result, tokens)
    end)
  end)

  case:execute()
  case:display_stats()
  case:maybe_error()
end
