function yatm_core.list_sample(l)
  local c = #l
  return l[math.random(c)]
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
