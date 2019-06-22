function yatm_core.table_key_of(t, expected_value)
  for key,value in pairs(t) do
    if value == expected_value then
      return key
    end
  end
  return nil
end

--[[
Used to merge multiple map-like tables together, if you need to merge lists
use `list_concat/*` instead
]]
function yatm_core.table_merge(...)
  local result = {}
  for _,t in ipairs({...}) do
    for key,value in pairs(t) do
      result[key] = value
    end
  end
  return result
end

function yatm_core.table_deep_merge(...)
  local result = {}
  for _,t in ipairs({...}) do
    for key,value in pairs(t) do
      if type(result[key]) == "table" and type(value) == "table" and not result[key][1] and not value[1] then
        result[key] = yatm_core.table_deep_merge(result[key], value)
      else
        result[key] = value
      end
    end
  end
  return result
end

--
-- Makes a copy of the given table
--
function yatm_core.table_copy(t)
  return yatm_core.table_merge(t)
end

function yatm_core.table_put(t, k, v)
  t[k] = v
  return t
end

function yatm_core.table_keys(t)
  local keys = {}
  for key,_ in pairs(t) do
    table.insert(keys, key)
  end
  return keys
end

function yatm_core.table_values(t)
  local values = {}
  for _,value in pairs(t) do
    table.insert(values, value)
  end
  return values
end

function yatm_core.table_equals(a, b)
  local merged = yatm_core.table_merge(a, b)
  for key,_ in pairs(merged) do
    if a[key] ~= b[key] then
      return false
    end
  end
  return true
end

function yatm_core.table_includes_value(t, expected)
  for _, value in pairs(t) do
    if value == expected then
      return true
    end
  end
  return false
end

function yatm_core.table_intersperse(t, spacer)
  local count = #t
  local result = {}
  for index, item in ipairs(t) do
    table.insert(result, item)
    if index < count then
      table.insert(result, spacer)
    end
  end
  return result
end

function yatm_core.is_table_empty(t)
  for index, item in pairs(t) do
    return false
  end
  return true
end

local function flatten_reducer(t, index, value, depth)
  assert(depth < 20, "flatten depth exceeded, maybe there is a loop")
  if type(value) == "table" then
    for _,item in ipairs(value) do
      t, index = flatten_reducer(t, index, item, depth + 1)
    end
    return t, index
  else
    t[index] = value
    return t, index + 1
  end
end

function yatm_core.table_flatten(value)
  return flatten_reducer({}, 1, value, 0)
end
