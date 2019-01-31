return function ()
  print("Benchmarking and testing OKU memory")
  local oku = yatm_oku.OKU.new()
  local last_value = {0}
  local time_then = os.clock()
  for i=0,math.pow(2, 16) - 1 do
    if i > 0 then
      local last_slice = oku:get_memory(i - 1)
      assert(last_slice[1] == last_value[1], "expected previous cell to be equal to last_value " .. last_value[1] .. " got " .. last_slice[1])
    end
    local slice = oku:get_memory(i)
    local type_name = type(slice)
    assert(type_name == "table", "expected a table at " .. i .. " got " .. type_name)
    assert(#slice == 1, "expected result at " .. i .. " to contain only 1 element got " .. #slice)
    assert(slice[1] == 0, "expected current cell " .. i .. " to be `0` got " .. "`" .. slice[1] .. "`")
    local value = math.random(255)
    oku:put_memory(i, value)
    local new_slice = oku:get_memory(i)
    assert(new_slice[1] == value, "expected current cell to be changed to " .. value .. " got " .. new_slice[1])
    if i > 0 then
      local last_slice = oku:get_memory(i - 1)
      assert(last_slice[1] == last_value[1], "expected previous cell to be equal to last_value " .. last_slice[1])
    end
    last_value = {value}
  end
  local time_now = os.clock()
  print("TIME ELAPSED", time_now - time_then)
end
