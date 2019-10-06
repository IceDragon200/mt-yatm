function yatm_core.list_map(list, fun)
  return yatm_core.list_reduce(list, {}, function (value, acc)
    table.insert(acc, fun(value))
    return acc, false
  end)
end

function yatm_core.list_reduce(list, acc, fun)
  local should_break
  for _, v in ipairs(list) do
    acc, should_break = fun(v, acc)
    if should_break then
      break
    end
  end
  return acc
end

function yatm_core.list_sample(l)
  local c = #l
  return l[math.random(c)]
end

function yatm_core.list_get_next(list, current)
  -- returns the next element in a list given the current value,
  -- if the current is nil,
  -- it will return the first element in the list
  if current then
    local index = yatm_core.table_key_of(list, current)
    if index then
      -- adjust the index by -1
      local index0 = index - 1
      -- then increment the 0-ed index and modulo it against the size of the list
      local next_index = (index0 + 1) % #list
      -- finally return the next element by incrementing the new_index by 1 to return it to normal
      return list[next_index + 1]
    else
      return list[1]
    end
  else
    return list[1]
  end
end

--[[
Not to be confused with table.concat, which is actually a 'join' in other languages.
]]
function yatm_core.list_concat(...)
  local result = {}
  local i = 1
  for _,t in ipairs({...}) do
    for _,element in ipairs(t) do
      result[i] = element
      i = i + 1
    end
  end
  return result
end

function yatm_core.list_uniq(l)
  local seen = {}
  local result = {}
  for _,e in ipairs(l) do
    if not seen[e] then
      seen[e] = true
      table.insert(result, e)
    end
  end
  return result
end
