function yatm_core.vec3_to_string(vec3)
  return "(" .. vec3.x .. ", " .. vec3.y .. ", " .. vec3.z .. ")"
end

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

function yatm_core.table_equals(a, b)
  local merged = table_merge(a, b)
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

function yatm_core.string_starts_with(str, expected)
  return expected == "" or string.sub(str, 1, #expected) == expected
end

function yatm_core.string_ends_with(str, expected)
  return expected == "" or string.sub(str, -#expected) == expected
end

local PREFIXES = {
  --{"yotta", "Y", 1000000000000000000000000},
  --{"zetta", "Z", 1000000000000000000000},
  --{"exa", "E", 1000000000000000000},
  --{"peta", "P", 1000000000000000},
  {"tera", "T", 1000000000000},
  {"giga", "G", 1000000000},
  {"mega", "M", 1000000},
  {"kilo", "k", 1000},
  --{"hecto", "h", 100},
  --{"deca", "da", 10},
  {"", "", 1},
  --{"deci", "d", 0.1},
  --{"centi", "c", 0.01},
  {"milli", "m", 0.001},
  {"micro", "μ", 0.000001},
  {"nano", "n", 0.000000001},
  --{"pico", "p", 0.000000000001},
  --{"femto", "f", 0.000000000000001},
  --{"atto", "a", 0.000000000000000001},
  --{"zepto", "z", 0.000000000000000000001},
  --{"yocto", "y", 0.000000000000000000000001},
}

function yatm_core.format_pretty_unit(value, unit)
  unit = unit or ""
  local result = tostring(value)
  for _,row in ipairs(PREFIXES) do
    -- until the unit is less than the value
    if row[3] < value then
      result = string.format("%.2f", value / row[3]) .. row[2]
      break
    end
  end
  return result .. unit
end
