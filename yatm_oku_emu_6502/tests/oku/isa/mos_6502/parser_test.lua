local mod = assert(yatm_oku_emu_6502)

local Luna = assert(foundation.com.Luna)
local isa = assert(yatm_oku.OKU.isa.MOS6502)
local Lexer = assert(isa.Lexer)
local Subject = assert(isa.Parser)

local case = Luna:new(Subject._name)

case:describe("#initialize/0", function (t2)
  t2:test("can initialize a new parser", function (t3)
    local parser = Subject:new()

    t3:assert(parser)
  end)
end)

case:describe("#parse/1", function (t2)
  t2:test("can parse a program with constant zeropage", function (t3)
    local lexer = Lexer:new()
    local ltokens = lexer:tokenize([[
    .const ADDR $20
    main:
      lda ADDR
      adc #2
    ]])

    local parser = Subject:new()
    ltokens:reopen("r")
    local ptokens = parser:parse(ltokens)
    t3:assert(ltokens:isEOB())

    ptokens:reopen("r")
    t3:assert_matches(ptokens:next_token(), {
      "label",
      "main",
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "lda",
        args = {
          {
            "zeropage",
            32,
            {},
          }
        }
      },
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "adc",
        args = {
          {
            "immediate",
            2,
            {},
          }
        }
      },
      {},
    })
    t3:assert(ptokens:isEOB())
  end)

  t2:test("can parse a program with constant absolute", function (t3)
    local lexer = Lexer:new()
    local ltokens = lexer:tokenize([[
    .const ADDR $1020
    main:
      lda ADDR
      adc #2
    ]])

    local parser = Subject:new()
    ltokens:reopen("r")
    local ptokens = parser:parse(ltokens)
    t3:assert(ltokens:isEOB())

    ptokens:reopen("r")
    t3:assert_matches(ptokens:next_token(), {
      "label",
      "main",
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "lda",
        args = {
          {
            "absolute",
            4128,
            {},
          }
        }
      },
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "adc",
        args = {
          {
            "immediate",
            2,
            {},
          }
        }
      },
      {},
    })
    t3:assert(ptokens:isEOB())
  end)

  t2:test("can parse a program with constant indirect Y", function (t3)
    local lexer = Lexer:new()
    local ltokens = lexer:tokenize([[
    .const ADDR $1020
    main:
      lda (ADDR),Y
      adc #2
    ]])

    local parser = Subject:new()
    ltokens:reopen("r")
    local ptokens = parser:parse(ltokens)
    t3:assert(ltokens:isEOB())

    ptokens:reopen("r")
    t3:assert_matches(ptokens:next_token(), {
      "label",
      "main",
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "lda",
        args = {
          {
            "indirect_y",
            4128,
            {},
          }
        }
      },
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "adc",
        args = {
          {
            "immediate",
            2,
            {},
          }
        }
      },
      {},
    })
    t3:assert(ptokens:isEOB())
  end)

  t2:test("can parse a program with constant indirect X", function (t3)
    local lexer = Lexer:new()
    local ltokens = lexer:tokenize([[
    .const ADDR $1020
    main:
      lda (ADDR,X)
      adc #2
    ]])

    local parser = Subject:new()
    ltokens:reopen("r")
    local ptokens = parser:parse(ltokens)
    t3:assert(ltokens:isEOB())

    ptokens:reopen("r")
    t3:assert_matches(ptokens:next_token(), {
      "label",
      "main",
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "lda",
        args = {
          {
            "indirect_x",
            32, -- truncation
            {},
          }
        }
      },
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "adc",
        args = {
          {
            "immediate",
            2,
            {},
          }
        }
      },
      {},
    })
    t3:assert(ptokens:isEOB())
  end)

  t2:test("can parse a program with constant immediate", function (t3)
    local lexer = Lexer:new()
    local ltokens = lexer:tokenize([[
    .const ADDR $20
    main:
      lda #ADDR
      adc #2
    ]])

    local parser = Subject:new()
    ltokens:reopen("r")
    local ptokens = parser:parse(ltokens)
    t3:assert(ltokens:isEOB())

    ptokens:reopen("r")
    t3:assert_matches(ptokens:next_token(), {
      "label",
      "main",
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "lda",
        args = {
          {
            "immediate",
            32,
            {},
          }
        }
      },
      {},
    })
    t3:assert_matches(ptokens:next_token(), {
      "ins",
      {
        name = "adc",
        args = {
          {
            "immediate",
            2,
            {},
          }
        }
      },
      {},
    })
    t3:assert(ptokens:isEOB())
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
