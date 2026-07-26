local mod = assert(yatm_oku_emu_6502)

local Luna = assert(foundation.com.Luna)
local isa = assert(yatm_oku.OKU.isa.MOS6502)
local Subject = assert(isa.Lexer)

local case = Luna:new(Subject._name)

case:describe("#initialize/0", function (t2)
  t2:test("will initialize a new lexer", function (t3)
    local lexer = Subject:new()

    t3:assert(lexer)
  end)
end)

case:describe("#tokenize/1", function (t2)
  t2:test("can handle an assembler directive", function (t3)
    local lexer = Subject:new()

    local tokens, rest = lexer:tokenize(".org $0800\n.word 25\n.byte \"A\"")

    tokens:reopen("r")
    t3:assert_eq(rest, "")
    t3:assert(tokens)
    t3:assert_matches(tokens:next_token(), {
      "directive",
      ".org",
      { pos = 1, len = 4 },
    })
    t3:assert_matches(tokens:next_token(), {
      "ws",
      " ",
      { pos = 5, len = 1 },
    })
    t3:assert_matches(tokens:next_token(), {
      "hex",
      "0800",
      { pos = 6, len = 5 },
    })
    t3:assert_matches(tokens:next_token(), {
      "nl",
      "\n",
      { pos = 11, len = 1 },
    })
    t3:assert_matches(tokens:next_token(), {
      "directive",
      ".word",
      { pos = 12, len = 5 },
    })
    t3:assert_matches(tokens:next_token(), {
      "ws",
      " ",
      { pos = 17, len = 1 },
    })
    t3:assert_matches(tokens:next_token(), {
      "integer",
      25,
      { pos = 18, len = 2 },
    })
    t3:assert_matches(tokens:next_token(), {
      "nl",
      "\n",
      { pos = 20, len = 1 },
    })
    t3:assert_matches(tokens:next_token(), {
      "directive",
      ".byte",
      { pos = 21, len = 5 },
    })
    t3:assert_matches(tokens:next_token(), {
      "ws",
      " ",
      { pos = 26, len = 1 },
    })
    t3:assert_matches(tokens:next_token(), {
      "dquote",
      "A",
      { pos = 27, len = 3 },
    })
    t3:assert(tokens:isEOB())
  end)

  t2:test("can tokenize comments", function (t3)
    local lexer = Subject:new()

    local tokens, rest = lexer:tokenize("; Hello, this is a comment.")
    tokens:reopen("r")
    t3:assert_eq(rest, "")

    t3:assert_matches(tokens:next_token(), {
      "comment",
      " Hello, this is a comment.",
      { pos = 1, len = 27 }
    })
  end)
end)

case:describe("tokenize/1 (individual tokens)", function (t2)
  local lexer = Subject:new()
  t2:test("can tokenize a comment", function (t3)
    local token_buf, rest = lexer:tokenize("; this is a comment")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("comment"))
  end)

  t2:test("can tokenize comma", function (t3)
    local token_buf, rest = lexer:tokenize(",")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens(","))
  end)

  t2:test("can tokenize hash", function (t3)
    local token_buf, rest = lexer:tokenize("#")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("#"))
  end)

  t2:test("can tokenize colon", function (t3)
    local token_buf, rest = lexer:tokenize(":")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens(":"))
  end)

  t2:test("can tokenize open-round-bracket", function (t3)
    local token_buf, rest = lexer:tokenize("(")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("("))
  end)

  t2:test("can tokenize closed-round-bracket", function (t3)
    local token_buf, rest = lexer:tokenize(")")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens(")"))
  end)

  t2:test("can tokenize newlines (lf)", function (t3)
    local token_buf, rest = lexer:tokenize("\n")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("nl"))
  end)

  t2:test("can tokenize newlines (crlf)", function (t3)
    local token_buf, rest = lexer:tokenize("\r\n")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("nl"))
  end)

  t2:test("can tokenize single space", function (t3)
    local token_buf, rest = lexer:tokenize(" ")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("ws"))
  end)

  t2:test("can tokenize single space (as tab)", function (t3)
    local token_buf, rest = lexer:tokenize("\t")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("ws"))
  end)

  t2:test("can tokenize multiple spaces", function (t3)
    local token_buf, rest = lexer:tokenize("       ")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("ws"))
  end)

  t2:test("can tokenize multiple spaces (as tabs)", function (t3)
    local token_buf, rest = lexer:tokenize("\t\t")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("ws"))
  end)

  t2:test("can tokenize single char atom", function (t3)
    local token_buf, rest = lexer:tokenize("X")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("atom"))
    local tokens = token_buf:scan("atom")
    t3:assert_deep_eq({"atom", "X", { pos = 1, len = 1 }}, tokens[1])
  end)

  t2:test("can tokenize simple atom word", function (t3)
    local token_buf, rest = lexer:tokenize("word")
    t3:assert_eq("", rest)
    token_buf:open('r')
    t3:assert(token_buf:match_tokens("atom"))
    local tokens = token_buf:scan("atom")
    t3:assert_deep_eq({"atom", "word", { pos = 1, len = 4 }}, tokens[1])
  end)

  t2:test("can tokenize complex atoms", function (t3)
    local token_buf, rest = lexer:tokenize("_marker_with_spaces_and_1234")
    t3:assert_eq("", rest)
    token_buf:open('r')
    local tokens = token_buf:scan("atom")
    t3:assert(tokens[1])
    t3:assert_deep_eq(
      {"atom", "_marker_with_spaces_and_1234", { pos = 1, len = 28 }},
      tokens[1]
    )
  end)

  t2:test("can tokenize all numbers as atoms (leading underscore)", function (t3)
    local token_buf, rest = lexer:tokenize("_0123456789")
    t3:assert_eq("", rest)
    token_buf:open('r')
    local tokens = token_buf:scan("atom")
    t3:assert(tokens[1])
    t3:assert_deep_eq(
      {"atom", "_0123456789", { pos = 1, len = 11 }},
      tokens[1]
    )
  end)

  t2:test("can tokenize entire latin alphabet atoms", function (t3)
    local tokens
    local token_buf, rest = lexer:tokenize("the_quick_brown_fox_jumps_over_the_lazy_dog")
    t3:assert_eq("", rest)
    token_buf:open('r')
    tokens = token_buf:scan("atom")
    t3:assert(tokens[1])
    t3:assert_deep_eq(
      {"atom", "the_quick_brown_fox_jumps_over_the_lazy_dog", { pos = 1, len = 43 }},
      tokens[1]
    )

    token_buf, rest = lexer:tokenize("THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG")
    t3:assert_eq("", rest)
    token_buf:open('r')
    tokens = token_buf:scan("atom")
    t3:assert(tokens[1])
    t3:assert_deep_eq(
      {"atom", "THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG", { pos = 1, len = 43 }},
      tokens[1]
    )
  end)

  t2:test("can tokenize a decimal integer", function (t3)
    local token_buf, rest = lexer:tokenize("0")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("integer")
    t3:assert(tokens[1])
    t3:assert_deep_eq({"integer", 0, { pos = 1, len = 1 }}, tokens[1])


    token_buf, rest = lexer:tokenize("1234567890")
    t3:assert_eq("", rest)
    token_buf:open('r')

    tokens = token_buf:scan("integer")
    t3:assert(tokens[1])
    t3:assert_deep_eq({"integer", 1234567890, { pos = 1, len = 10 }}, tokens[1])
  end)

  t2:test("can tokenize $hex", function (t3)
    local token_buf, rest = lexer:tokenize("$00FF")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("hex")
    t3:assert(tokens[1])
    t3:assert_deep_eq({"hex", "00FF", { pos = 1, len = 5 }}, tokens[1])
  end)

  t2:test("can tokenize entire hex alphabet", function (t3)
    local token_buf, rest = lexer:tokenize("$0123456789ABCDEFabcdef")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("hex")
    t3:assert(tokens[1])
    t3:assert_deep_eq(
      {"hex", "0123456789ABCDEFabcdef", { pos = 1, len = 23 }},
      tokens[1]
    )
  end)

  t2:test("can tokenize an empty double-quoted string", function (t3)
    local token_buf, rest = lexer:tokenize("\"\"")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("dquote")
    t3:assert(tokens[1])
    t3:assert_deep_eq({"dquote", "", { pos = 1, len = 2 }}, tokens[1])
  end)

  t2:test("can tokenize a double-quoted string", function (t3)
    local token_buf, rest = lexer:tokenize("\"Hello\"")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("dquote")
    t3:assert(tokens[1])
    t3:assert_deep_eq({"dquote", "Hello", { pos = 1, len = 7 }}, tokens[1])
  end)

  t2:test("can tokenize a complex double-quoted string", function (t3)
    local token_buf, rest = lexer:tokenize("\"Hello World, how are you m8\"")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("dquote")
    t3:assert(tokens[1])
    t3:assert_deep_eq(
      tokens[1],
      {"dquote", "Hello World, how are you m8", { pos = 1, len = 29 }}
    )
  end)

  t2:test("can tokenize a double-quoted string with escape codes", function (t3)
    local token_buf, rest = lexer:tokenize("\"New\\nLine\\tTabs\\sSpaces\"")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("dquote")
    t3:assert(tokens[1])
    t3:assert_deep_eq(
      tokens[1],
      {"dquote", "New\nLine\tTabs Spaces", { pos = 1, len = 25 }}
    )
  end)

  t2:test("can tokenize an empty single-quoted string", function (t3)
    local token_buf, rest = lexer:tokenize("''")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("squote")
    t3:assert(tokens[1])
    t3:assert_deep_eq(tokens[1], {"squote", "", { pos = 1, len = 2 }})
  end)

  t2:test("can tokenize an a single-quoted string (ignoring escape codes)", function (t3)
    local token_buf, rest = lexer:tokenize("'\\n\\tHello, World\\s'")
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:scan("squote")
    t3:assert(tokens[1])
    t3:assert_deep_eq(
      tokens[1],
      {"squote", "\\n\\tHello, World\\s", { pos = 1, len = 20 }}
    )
  end)
end)

case:describe("tokenize/1 (stream)", function (t2)
  t2:test("can tokenize a simple program", function (t3)
    local lexer = Subject:new()

    local prog =
      "main:\n" ..
      "  LDA #0 ; zero accumulator\n" ..
      "  ADC #$20 ; add 32 to the accumulator"

    local token_buf, rest = lexer:tokenize(prog)
    t3:assert_eq("", rest)
    token_buf:open('r')

    local tokens = token_buf:to_list()

    local result = {
      {"atom", "main", {}}, {":", true, {}}, {"nl", "\n", {}},
      {"ws", "  ", {}}, {"atom", "LDA", {}}, {"ws", " ", {}}, {"#", true, {}}, {"integer", 0, {}}, {"ws", " ", {}}, {"comment", " zero accumulator", {}}, {"nl", "\n", {}},
      {"ws", "  ", {}}, {"atom", "ADC", {}}, {"ws", " ", {}}, {"#", true, {}}, {"hex", "20", {}}, {"ws", " ", {}}, {"comment", " add 32 to the accumulator", {}}
    }
    t3:assert_matches(tokens, result)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
