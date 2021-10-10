local Luna = assert(foundation.com.Luna)
local m = yatm_oku.OKU
local Buffer = assert(foundation.com.BinaryBuffer or foundation.com.StringBuffer)

if not m then
  yatm.warn("OKU not available for tests")
  return
end

local case = Luna:new("yatm_oku.OKU")

case:describe("memory benchmark", function (t2)
  t2:xtest("addressing memory slices", function (t3)
    print("Creating oku for memory slice test")
    local oku = yatm_oku.OKU:new()
    local last_value = {0}
    for i=0,oku.memory.size - 1 do
      if i > 0 then
        local last_slice = oku:get_memory_slice(i - 1)
        assert(last_slice[1] == last_value[1], "expected previous cell to be equal to last_value " .. last_value[1] .. " got " .. last_slice[1])
      end
      local slice = oku:get_memory_slice(i)
      local type_name = type(slice)
      t3:assert(type_name == "table", "expected a table at " .. i .. " got " .. type_name)
      t3:assert(#slice == 1, "expected result at " .. i .. " to contain only 1 element got " .. #slice)
      t3:assert(slice[1] == 0, "expected current cell " .. i .. " to be `0` got " .. "`" .. slice[1] .. "`")
      local value = math.random(127)
      oku:put_memory(i, value)
      local new_slice = oku:get_memory_slice(i)
      t3:assert(new_slice[1] == value, "expected current cell to be changed to " .. value .. " got " .. new_slice[1])
      if i > 0 then
        local last_slice = oku:get_memory_slice(i - 1)
        t3:assert(last_slice[1] == last_value[1], "expected previous cell to be equal to last_value " .. last_slice[1])
      end
      last_value = {value}
    end
  end)

  t2:xtest("addressing memory bytes", function (t3)
    local oku = yatm_oku.OKU:new()

    for i=0,oku.memory.size - 1 do
      t3:assert_eq(oku:get_memory_byte(i), 0)
      local value = math.random(127)
      oku:put_memory_byte(i, value)
      t3:assert_eq(oku:get_memory_byte(i), value)
    end
  end)
end)

case:describe("step_ins", function (t2)
  t2:describe("arithi/ADDI", function (t3)
  end)
end)

case:describe("step (rv32i)", function (t2)
  if yatm_oku.elf then
    t2:test("run a simple RISCV program", function (t3)
      local oku =
        m:new({
          arch = "rv32i"
        })

      --oku:load_elf_binary('\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00\x01\x00\x00\x00\x98\x00\x01\x00\x34\x00\x00\x00\x54\x02\x00\x00\x00\x00\x00\x00\x34\x00\x20\x00\x02\x00\x28\x00\x07\x00\x06\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x01\x00\xc0\x00\x00\x00\xc0\x00\x00\x00\x05\x00\x00\x00\x00\x10\x00\x00\x04\x00\x00\x00\x74\x00\x00\x00\x74\x00\x01\x00\x74\x00\x01\x00\x24\x00\x00\x00\x24\x00\x00\x00\x04\x00\x00\x00\x04\x00\x00\x00\x04\x00\x00\x00\x14\x00\x00\x00\x03\x00\x00\x00\x47\x4e\x55\x00\x66\x09\x1f\x24\xfb\x1f\x4a\x99\xca\x65\xe9\x39\x01\x89\xc7\xe7\x53\x71\xf9\xf0\x13\x01\x01\xfe\x23\x2e\x81\x00\x13\x04\x01\x02\x23\x26\xa4\xfe\x23\x24\xb4\xfe\x93\x07\x00\x00\x13\x85\x07\x00\x03\x24\xc1\x01\x13\x01\x01\x02\x67\x80\x00\x00\x47\x43\x43\x3a\x20\x28\x47\x4e\x55\x29\x20\x39\x2e\x32\x2e\x30\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x74\x00\x01\x00\x00\x00\x00\x00\x03\x00\x01\x00\x00\x00\x00\x00\x98\x00\x01\x00\x00\x00\x00\x00\x03\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x03\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\xf1\xff\x08\x00\x00\x00\xc0\x18\x01\x00\x00\x00\x00\x00\x10\x00\xf1\xff\x1a\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x3b\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x2a\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x36\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x42\x00\x00\x00\x98\x00\x01\x00\x28\x00\x00\x00\x12\x00\x02\x00\x47\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x56\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x5d\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x00\x70\x72\x6f\x67\x2e\x63\x00\x5f\x5f\x67\x6c\x6f\x62\x61\x6c\x5f\x70\x6f\x69\x6e\x74\x65\x72\x24\x00\x5f\x5f\x53\x44\x41\x54\x41\x5f\x42\x45\x47\x49\x4e\x5f\x5f\x00\x5f\x5f\x42\x53\x53\x5f\x45\x4e\x44\x5f\x5f\x00\x5f\x5f\x62\x73\x73\x5f\x73\x74\x61\x72\x74\x00\x6d\x61\x69\x6e\x00\x5f\x5f\x44\x41\x54\x41\x5f\x42\x45\x47\x49\x4e\x5f\x5f\x00\x5f\x65\x64\x61\x74\x61\x00\x5f\x65\x6e\x64\x00\x00\x2e\x73\x79\x6d\x74\x61\x62\x00\x2e\x73\x74\x72\x74\x61\x62\x00\x2e\x73\x68\x73\x74\x72\x74\x61\x62\x00\x2e\x6e\x6f\x74\x65\x2e\x67\x6e\x75\x2e\x62\x75\x69\x6c\x64\x2d\x69\x64\x00\x2e\x74\x65\x78\x74\x00\x2e\x63\x6f\x6d\x6d\x65\x6e\x74\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1b\x00\x00\x00\x07\x00\x00\x00\x02\x00\x00\x00\x74\x00\x01\x00\x74\x00\x00\x00\x24\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x2e\x00\x00\x00\x01\x00\x00\x00\x06\x00\x00\x00\x98\x00\x01\x00\x98\x00\x00\x00\x28\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x34\x00\x00\x00\x01\x00\x00\x00\x30\x00\x00\x00\x00\x00\x00\x00\xc0\x00\x00\x00\x11\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xd4\x00\x00\x00\xe0\x00\x00\x00\x05\x00\x00\x00\x05\x00\x00\x00\x04\x00\x00\x00\x10\x00\x00\x00\x09\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xb4\x01\x00\x00\x62\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x11\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x16\x02\x00\x00\x3d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00')
      oku:call_arch('load_elf_binary', '\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00\x01\x00\x00\x00\x98\x00\x01\x00\x34\x00\x00\x00\x5c\x02\x00\x00\x00\x00\x00\x00\x34\x00\x20\x00\x02\x00\x28\x00\x07\x00\x06\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x01\x00\xdc\x00\x00\x00\xdc\x00\x00\x00\x05\x00\x00\x00\x00\x10\x00\x00\x04\x00\x00\x00\x74\x00\x00\x00\x74\x00\x01\x00\x74\x00\x01\x00\x24\x00\x00\x00\x24\x00\x00\x00\x04\x00\x00\x00\x04\x00\x00\x00\x04\x00\x00\x00\x14\x00\x00\x00\x03\x00\x00\x00\x47\x4e\x55\x00\x2b\xe9\xd9\xcc\x7a\x55\x49\x2c\xde\xa6\x6c\xb9\x45\xbc\x73\x3a\x7f\x8a\x99\x1a\x13\x01\x01\xfe\x23\x2e\x81\x00\x13\x04\x01\x02\x93\x07\x00\x07\x23\x26\xf4\xfe\x83\x27\xc4\xfe\x23\xa0\x07\x00\x83\x27\xc4\xfe\x83\xa7\x07\x00\x63\x9a\x07\x00\x83\x27\xc4\xfe\x13\x07\x10\x00\x23\xa0\xe7\x00\x6f\xf0\x9f\xfe\x83\x27\xc4\xfe\x23\xa0\x07\x00\x6f\xf0\xdf\xfd\x47\x43\x43\x3a\x20\x28\x47\x4e\x55\x29\x20\x39\x2e\x32\x2e\x30\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x74\x00\x01\x00\x00\x00\x00\x00\x03\x00\x01\x00\x00\x00\x00\x00\x98\x00\x01\x00\x00\x00\x00\x00\x03\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x03\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\xf1\xff\x08\x00\x00\x00\xdc\x18\x01\x00\x00\x00\x00\x00\x10\x00\xf1\xff\x1a\x00\x00\x00\xdc\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x3b\x00\x00\x00\x98\x00\x01\x00\x44\x00\x00\x00\x12\x00\x02\x00\x2a\x00\x00\x00\xdc\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x36\x00\x00\x00\xdc\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x42\x00\x00\x00\xdc\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x51\x00\x00\x00\xdc\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x58\x00\x00\x00\xdc\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x00\x6c\x6f\x6f\x70\x2e\x63\x00\x5f\x5f\x67\x6c\x6f\x62\x61\x6c\x5f\x70\x6f\x69\x6e\x74\x65\x72\x24\x00\x5f\x5f\x53\x44\x41\x54\x41\x5f\x42\x45\x47\x49\x4e\x5f\x5f\x00\x5f\x5f\x42\x53\x53\x5f\x45\x4e\x44\x5f\x5f\x00\x5f\x5f\x62\x73\x73\x5f\x73\x74\x61\x72\x74\x00\x5f\x5f\x44\x41\x54\x41\x5f\x42\x45\x47\x49\x4e\x5f\x5f\x00\x5f\x65\x64\x61\x74\x61\x00\x5f\x65\x6e\x64\x00\x00\x2e\x73\x79\x6d\x74\x61\x62\x00\x2e\x73\x74\x72\x74\x61\x62\x00\x2e\x73\x68\x73\x74\x72\x74\x61\x62\x00\x2e\x6e\x6f\x74\x65\x2e\x67\x6e\x75\x2e\x62\x75\x69\x6c\x64\x2d\x69\x64\x00\x2e\x74\x65\x78\x74\x00\x2e\x63\x6f\x6d\x6d\x65\x6e\x74\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1b\x00\x00\x00\x07\x00\x00\x00\x02\x00\x00\x00\x74\x00\x01\x00\x74\x00\x00\x00\x24\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x2e\x00\x00\x00\x01\x00\x00\x00\x06\x00\x00\x00\x98\x00\x01\x00\x98\x00\x00\x00\x44\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x34\x00\x00\x00\x01\x00\x00\x00\x30\x00\x00\x00\x00\x00\x00\x00\xdc\x00\x00\x00\x11\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf0\x00\x00\x00\xd0\x00\x00\x00\x05\x00\x00\x00\x05\x00\x00\x00\x04\x00\x00\x00\x10\x00\x00\x00\x09\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x01\x00\x00\x5d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x11\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1d\x02\x00\x00\x3d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00%')
      oku:call_arch('reset_sp')

      for _ = 1,20 do
        oku:step(1)
        --print(dump(oku:r_memory_blob(0, 0xFF)))
      end

      --error("NO")
    end)
  end
end)

case:describe("step (mos6502)", function (t2)
  if m:has_arch("mos6502") then
    t2:test("runs a simple 6502 program", function (t3)
      local oku =
        m:new({
          arch = "mos6502"
        })

      local b = m.isa.MOS6502.Builder

      local blob =
        b.lda_imm(0) ..
        b.adc_imm(20)

      oku:w_memory_blob(512, blob)
      oku:w_memory_blob(0xFFFC, "\x00\x02")

      -- reset sequence is roughly 9 steps
      for i = 1,9 do
        t3:assert_eq(1, oku:step(1))
      end
      t3:assert_eq(2, oku.isa_assigns.chip:get_state())
      t3:assert_eq(512, oku.isa_assigns.chip:get_register_pc())

      t3:assert_eq(1, oku:step(1))
      t3:assert_eq(514, oku.isa_assigns.chip:get_register_pc())

      t3:assert_eq(0, oku.isa_assigns.chip:get_register_a())

      t3:assert_eq(1, oku:step(1))
      t3:assert_eq(20, oku.isa_assigns.chip:get_register_a())
    end)
  else
    t2:xtest("mos6502 unavailable", function ()
    end)
  end
end)

case:describe("bindump/1", function (t2)
  if m:has_arch("mos6502") then
    t2:test("can dump a mos6502 machine", function (t3)
      local oku =
        m:new({
          arch = "mos6502"
        })

      local stream = Buffer:new('', 'w')

      oku:bindump(stream)
    end)
  else
    t2:xtest("mos6502 unavailable", function ()
    end)
  end

  if m:has_arch("rv32i") then
    t2:test("can dump a riscv rv32i machine", function (t3)
      local oku =
        m:new({
          arch = "rv32i"
        })

      local stream = Buffer:new('', 'w')

      oku:bindump(stream)
    end)
  else
    t2:xtest("riscv rv32i unavailable", function ()
    end)
  end
end)

case:describe("binload/1", function (t2)
  if m:has_arch("mos6502") then
    t2:test("can load a mos6502 machine", function (t3)
      local oku =
        m:new({
          arch = "mos6502",
          label = "awesome label",
        })

      oku.isa_assigns.chip:set_register_a(127)
      oku.isa_assigns.chip:set_register_x(76)
      oku.isa_assigns.chip:set_register_y(32)
      local stream = Buffer:new('', 'w')

      oku:bindump(stream)
      stream:close()

      local oku =
        m:new({
          arch = "mos6502",
          label = "awesome label",
        })

      stream:open('r')
      oku:binload(stream)

      t3:assert_eq(oku.arch, "mos6502")
      t3:assert_eq(oku.label, "awesome label")
      t3:assert_eq(oku.isa_assigns.chip:get_register_a(), 127)
      t3:assert_eq(oku.isa_assigns.chip:get_register_x(), 76)
      t3:assert_eq(oku.isa_assigns.chip:get_register_y(), 32)
    end)
  else
    t2:xtest("mos6502 unavailable", function ()
    end)
  end

  if m:has_arch("rv32i") then
    t2:test("can dump a riscv rv32i machine", function (t3)
      local oku =
        m:new({
          arch = "rv32i",
          label = "awesome label",
        })

      local stream = Buffer:new('', 'w')

      oku:bindump(stream)
      stream:close()
      stream:open('r')
      oku:binload(stream)

      t3:assert_eq(oku.arch, "rv32i")
      t3:assert_eq(oku.label, "awesome label")
    end)
  else
    t2:xtest("riscv rv32i unavailable", function ()
    end)
  end
end)

case:execute()
case:display_stats()
case:maybe_error()
