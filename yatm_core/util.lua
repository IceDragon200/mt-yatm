function yatm_core.vec3_to_string(vec3)
  return "(" .. vec3.x .. ", " .. vec3.y .. ", " .. vec3.z .. ")"
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

--[[
Makes a copy of the given table
]]
function yatm_core.table_copy(t)
  return yatm_core.table_merge(t)
end

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

function yatm_core.string_starts_with(str, expected)
  return expected == "" or string.sub(str, 1, #expected) == expected
end

function yatm_core.string_ends_with(str, expected)
  return expected == "" or string.sub(str, -#expected) == expected
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

function yatm_core.iodata_to_string(value)
  if type(value) == "string" then
    return value
  elseif type(value) == "table" then
    local result = yatm_core.table_flatten(value)
    return table.concat(result)
  else
    error("unexpected value " .. dump(value))
  end
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

function yatm_core.inspect_itemstack(stack)
  if stack then
    return "stack[" .. stack:get_name() .. "/" .. stack:get_count() .. "]"
  else
    return "nil"
  end
end

function yatm_core.is_blank(value)
  if value == nil then
    return true
  elseif value == "" then
    return true
  else
    return false
  end
end

function yatm_core.itemstack_is_blank(stack)
  if stack then
    return yatm_core.is_blank(stack:get_name()) or stack:get_count() == 0
  else
    return true
  end
end

local STRING_POOL = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local STRING_POOL16 = "ABCDEF0123456789"

function yatm_core.random_string(length, pool)
  pool = pool or STRING_POOL
  local pool_size = #pool
  local result = {}
  for i = 1,length do
    local pos = math.random(pool_size - 1)
    result[i] = assert(string.sub(pool, pos, pos))
  end
  return table.concat(result)
end

function yatm_core.random_string16(length)
  return yatm_core.random_string(length, STRING_POOL16)
end

local function assert_itemstack_meta(itemstack)
  if not itemstack or not itemstack.get_meta then
    error("expected an itemstack with get_meta function (got " .. dump(itemstack) .. ")")
  end
end

function yatm_core.get_itemstack_description(itemstack)
  assert_itemstack_meta(itemstack)
  local desc = itemstack:get_meta():get_string("description")
  if yatm_core.is_blank(desc) then
    local itemdef = minetest.registered_items[itemstack:get_name()]
    return itemdef.description or itemstack:get_name()
  else
    return desc
  end
end

function yatm_core.set_itemstack_meta_description(itemstack, description)
  assert_itemstack_meta(itemstack)
  itemstack:get_meta():set_string("description", description)
  return itemstack
end
