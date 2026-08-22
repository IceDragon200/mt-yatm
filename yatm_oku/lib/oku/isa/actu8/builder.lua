local ACTU8 = assert(yatm_oku.OKU.isa.ACTU8)
local BE_LE = assert(foundation.com.ByteEncoder.LE)
local char = string.char

--- @namespace yatm_coku.OKU.isa.ACTU8.Builder
local m = {}
do
  --- @spec nop(): String
  function m.nop()
    return "\x00"
  end

  --- @spec halt(): String
  function m.halt()
    return "\x01"
  end

  --- @spec ldi(imm: Integer): String
  function m.ldi(imm)
    return "\x10" .. char(imm)
  end

  --- @spec lda(addr8: Integer): String
  function m.lda(addr8)
    return "\x11" .. char(addr8)
  end

  --- @spec sta(addr8: Integer): String
  function m.sta(addr8)
    return "\x12" .. char(addr8)
  end

  --- @spec push(): String
  function m.push()
    return "\x13"
  end

  --- @spec pop(): String
  function m.pop()
    return "\x14"
  end

  --- @spec add(addr8: Integer): String
  function m.add(addr8)
    return "\x20" .. char(addr8)
  end

  --- @spec sub(addr8: Integer): String
  function m.sub(addr8)
    return "\x21" .. char(addr8)
  end

  --- @spec cmp(addr8: Integer): String
  function m.cmp(addr8)
    return "\x22" .. char(addr8)
  end

  --- @spec b_and(addr8: Integer): String
  function m.b_and(addr8)
    return "\x30" .. char(addr8)
  end
  m["and"] = m.b_and

  --- @spec b_or(addr8: Integer): String
  function m.b_or(addr8)
    return "\x31" .. char(addr8)
  end
  m["or"] = m.b_or

  --- @spec b_xor(addr8: Integer): String
  function m.b_xor(addr8)
    return "\x32" .. char(addr8)
  end
  m["xor"] = m.b_xor

  --- @spec clz(): String
  function m.clz()
    return "\x40"
  end

  --- @spec clc(): String
  function m.clc()
    return "\x41"
  end

  --- @spec clb(): String
  function m.clb()
    return "\x42"
  end

  --- @spec cli(): String
  function m.cli()
    return "\x43"
  end

  --- @spec jmp(addr16: Integer): String
  function m.jmp(addr16)
    return "\x50" .. BE_LE:e_u16(addr16)
  end

  --- @spec call(addr16: Integer): String
  function m.call(addr16)
    return "\x51" .. BE_LE:e_u16(addr16)
  end

  --- @spec ret(): String
  function m.ret()
    return "\x52"
  end

  --- @spec jz(addr16: Integer): String
  function m.jz(addr16)
    return "\x60" .. BE_LE:e_u16(addr16)
  end

  --- @spec jnz(addr16: Integer): String
  function m.jnz(addr16)
    return "\x61" .. BE_LE:e_u16(addr16)
  end

  --- @spec jc(addr16: Integer): String
  function m.jc(addr16)
    return "\x62" .. BE_LE:e_u16(addr16)
  end

  --- @spec jnc(addr16: Integer): String
  function m.jnc(addr16)
    return "\x63" .. BE_LE:e_u16(addr16)
  end

  --- @spec jb(addr16: Integer): String
  function m.jb(addr16)
    return "\x64" .. BE_LE:e_u16(addr16)
  end

  --- @spec jnb(addr16: Integer): String
  function m.jnb(addr16)
    return "\x65" .. BE_LE:e_u16(addr16)
  end

  --- @spec ji(addr16: Integer): String
  function m.ji(addr16)
    return "\x66" .. BE_LE:e_u16(addr16)
  end

  --- @spec jni(addr16: Integer): String
  function m.jni(addr16)
    return "\x67" .. BE_LE:e_u16(addr16)
  end

  --- @spec io_in(addr16: Integer): String
  function m.io_in(addr8)
    return "\x70" .. char(addr8)
  end
  m["in"] = m.io_in

  --- @spec out(addr16: Integer): String
  function m.out(addr8)
    return "\x71" .. char(addr8)
  end
end

ACTU8.Builder = m
