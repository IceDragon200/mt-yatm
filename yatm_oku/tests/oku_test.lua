local Luna = assert(yatm_core.Luna)

local case = Luna:new("yatm_oku.OKU")

case:describe("memory benchmark", function (t2)
  t2:xtest("addressing memory slices", function (t3)
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

  t2:test("addressing memory bytes", function (t3)
    local oku = yatm_oku.OKU:new()

    for i=0,oku.memory.size - 1 do
      t3:assert_eq(oku:get_memory_byte(i), 0)
      local value = math.random(127)
      oku:put_memory_byte(i, value)
      t3:assert_eq(oku:get_memory_byte(i), value)
    end
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
