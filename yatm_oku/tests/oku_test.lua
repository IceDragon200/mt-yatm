local Luna = assert(yatm_core.Luna)

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

case:describe("step", function (t2)
  t2:test("run a simple riscv program", function (t3)
    local oku = yatm_oku.OKU:new()

    oku:load_elf_binary('\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00\x01\x00\x00\x00\x98\x00\x01\x00\x34\x00\x00\x00\x54\x02\x00\x00\x00\x00\x00\x00\x34\x00\x20\x00\x02\x00\x28\x00\x07\x00\x06\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x01\x00\xc0\x00\x00\x00\xc0\x00\x00\x00\x05\x00\x00\x00\x00\x10\x00\x00\x04\x00\x00\x00\x74\x00\x00\x00\x74\x00\x01\x00\x74\x00\x01\x00\x24\x00\x00\x00\x24\x00\x00\x00\x04\x00\x00\x00\x04\x00\x00\x00\x04\x00\x00\x00\x14\x00\x00\x00\x03\x00\x00\x00\x47\x4e\x55\x00\x66\x09\x1f\x24\xfb\x1f\x4a\x99\xca\x65\xe9\x39\x01\x89\xc7\xe7\x53\x71\xf9\xf0\x13\x01\x01\xfe\x23\x2e\x81\x00\x13\x04\x01\x02\x23\x26\xa4\xfe\x23\x24\xb4\xfe\x93\x07\x00\x00\x13\x85\x07\x00\x03\x24\xc1\x01\x13\x01\x01\x02\x67\x80\x00\x00\x47\x43\x43\x3a\x20\x28\x47\x4e\x55\x29\x20\x39\x2e\x32\x2e\x30\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x74\x00\x01\x00\x00\x00\x00\x00\x03\x00\x01\x00\x00\x00\x00\x00\x98\x00\x01\x00\x00\x00\x00\x00\x03\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x03\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\xf1\xff\x08\x00\x00\x00\xc0\x18\x01\x00\x00\x00\x00\x00\x10\x00\xf1\xff\x1a\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x3b\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x2a\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x36\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x42\x00\x00\x00\x98\x00\x01\x00\x28\x00\x00\x00\x12\x00\x02\x00\x47\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x56\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x5d\x00\x00\x00\xc0\x10\x01\x00\x00\x00\x00\x00\x10\x00\x02\x00\x00\x70\x72\x6f\x67\x2e\x63\x00\x5f\x5f\x67\x6c\x6f\x62\x61\x6c\x5f\x70\x6f\x69\x6e\x74\x65\x72\x24\x00\x5f\x5f\x53\x44\x41\x54\x41\x5f\x42\x45\x47\x49\x4e\x5f\x5f\x00\x5f\x5f\x42\x53\x53\x5f\x45\x4e\x44\x5f\x5f\x00\x5f\x5f\x62\x73\x73\x5f\x73\x74\x61\x72\x74\x00\x6d\x61\x69\x6e\x00\x5f\x5f\x44\x41\x54\x41\x5f\x42\x45\x47\x49\x4e\x5f\x5f\x00\x5f\x65\x64\x61\x74\x61\x00\x5f\x65\x6e\x64\x00\x00\x2e\x73\x79\x6d\x74\x61\x62\x00\x2e\x73\x74\x72\x74\x61\x62\x00\x2e\x73\x68\x73\x74\x72\x74\x61\x62\x00\x2e\x6e\x6f\x74\x65\x2e\x67\x6e\x75\x2e\x62\x75\x69\x6c\x64\x2d\x69\x64\x00\x2e\x74\x65\x78\x74\x00\x2e\x63\x6f\x6d\x6d\x65\x6e\x74\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1b\x00\x00\x00\x07\x00\x00\x00\x02\x00\x00\x00\x74\x00\x01\x00\x74\x00\x00\x00\x24\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x2e\x00\x00\x00\x01\x00\x00\x00\x06\x00\x00\x00\x98\x00\x01\x00\x98\x00\x00\x00\x28\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x34\x00\x00\x00\x01\x00\x00\x00\x30\x00\x00\x00\x00\x00\x00\x00\xc0\x00\x00\x00\x11\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xd4\x00\x00\x00\xe0\x00\x00\x00\x05\x00\x00\x00\x05\x00\x00\x00\x04\x00\x00\x00\x10\x00\x00\x00\x09\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xb4\x01\x00\x00\x62\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x11\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x16\x02\x00\x00\x3d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00')

    error("NO")
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
