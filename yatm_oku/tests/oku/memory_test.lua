local Luna = assert(foundation.com.Luna)
local Buffer = assert(foundation.com.BinaryBuffer or foundation.com.StringBuffer)

if not yatm_oku.OKU then
  yatm.warn("Cannot test memory, OKU is not available\n")
  return
end

local modules = {}
if yatm_oku.OKU.FFIMemory then
  table.insert(modules, yatm_oku.OKU.FFIMemory)
else
  yatm.warn("FFIMemory module is unavailable\n")
end
if yatm_oku.OKU.LuaMemory then
  table.insert(modules, yatm_oku.OKU.LuaMemory)
else
  yatm.warn("LuaMemory module is unavailable\n")
end

for _,m in ipairs(modules) do
  local case = Luna:new(m.name)

  case:describe("#initialize", function (t2)
    t2:test("can initialize memory with 256 bytes of space", function (t3)
      local mem = m:new(256) -- really small memory for testing
    end)

    t2:test("can initialize memory with 65535 bytes of space", function (t3)
      local mem = m:new(65535) -- standard for computer memory
    end)
  end)

  case:describe("#w_blob", function (t2)
    t2:test("can write a blob to memory", function (t3)
      local mem = m:new(256)

      mem:w_blob(0, "Hello, World")

      t3:assert_eq(mem:r_blob(0, 12), "Hello, World")
    end)
  end)

  case:describe("#r_i8", function (t2)
    t2:test("can address bytes at location", function (t3)
      local mem = m:new(256) -- really small memory for testing

      t3:assert_eq(mem:r_i8(0), 0)
      mem:w_i8(0, 32)
      t3:assert_eq(mem:r_i8(0), 32)

      t3:assert_eq(mem:r_i8(1), 0)
      mem:w_i8(1, 87)
      t3:assert_eq(mem:r_i8(0), 32)
      t3:assert_eq(mem:r_i8(1), 87)

      t3:assert_eq(mem:r_i8(7), 0)
      mem:w_i8(7, 120)
      t3:assert_eq(mem:r_i8(0), 32)
      t3:assert_eq(mem:r_i8(1), 87)
      t3:assert_eq(mem:r_i8(7), 120)

      mem:w_i8(255, 16)
      t3:assert_eq(mem:r_i8(255), 16)
    end)
  end)

  case:describe("#r_bytes", function (t2)
    t2:test("can retrieve a list of bytes", function (t3)
      local mem = m:new(256)

      mem:w_i8b(0, 'H')
      mem:w_i8b(1, 'E')
      mem:w_i8b(2, 'L')
      mem:w_i8b(3, 'L')
      mem:w_i8b(4, 'O')

      local result = mem:r_bytes(0, 5)

      t3:assert_table_eq(result, {72, 69, 76, 76, 79})
    end)
  end)

  case:describe("#bindump and #binload", function (t2)
    t2:test("can dump and reload memory (256 bytes)", function (t3)
      local mem = m:new(256)
      local stream = Buffer:new('', 'w')

      mem:w_i8b(0, 'H')
      mem:w_i8b(1, 'E')
      mem:w_i8b(2, 'L')
      mem:w_i8b(3, 'L')
      mem:w_i8b(4, 'O')

      local result = mem:r_bytes(0, 5)

      t3:assert_table_eq(result, {72, 69, 76, 76, 79})

      local blob = mem:bindump(stream)
      stream:close()

      local newmem = m:new(256)

      stream:open('r')
      newmem:binload(stream)

      local result = newmem:r_bytes(0, 5)

      t3:assert_table_eq(result, {72, 69, 76, 76, 79})
    end)

    if foundation.com.BinaryBuffer then
      -- Takes too long to encode this normally

      t2:test("can dump and reload memory (65535 bytes)", function (t3)
        local mem = m:new(65535)
        local stream = Buffer:new('', 'w')

        mem:w_i8b(0, 'H')
        mem:w_i8b(1, 'E')
        mem:w_i8b(2, 'L')
        mem:w_i8b(3, 'L')
        mem:w_i8b(4, 'O')

        local result = mem:r_bytes(0, 5)

        t3:assert_table_eq(result, {72, 69, 76, 76, 79})

        local blob = mem:bindump(stream)
        stream:close()

        local newmem = m:new(65535)

        stream:open('r')
        newmem:binload(stream)

        local result = newmem:r_bytes(0, 5)

        t3:assert_table_eq(result, {72, 69, 76, 76, 79})
      end)
    end
  end)

  case:execute()
  case:display_stats()
  case:maybe_error()
end
