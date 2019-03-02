function yatm_core.table_merge(...)
  local result = {}
  for _,t in ipairs({...}) do
    for key,value in pairs(t) do
      result[key] = value
    end
  end
  return result
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
