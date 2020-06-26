--
-- Not table.concat (which is really just a join)
-- This is concat like any other sane language
-- @spec yatm_core.table_concat(...tables) :: table
function yatm_core.table_concat(...)
  local result = {}
  local i = 0
  for _,t in ipairs({...}) do
    for _,value in ipairs(t) do
      i = i + 1
      result[i] = value
    end
  end
  return result
end

--
-- Copy the specified keys from the given table, returning a new table with those keys
--
-- @spec yatm_core.table_take(t: Table, keys: [String]) :: Table
function yatm_core.table_take(t, keys)
  local result = {}

  for _, key in ipairs(keys) do
    result[key] = t[key]
  end

  return result
end

--
-- Removes the specified keys from the given table
-- This will return the same table.
--
-- @mutative
-- @spec yatm_core.table_drop(t: Table, keys: [String]) :: Table
function yatm_core.table_drop(t, keys)
  for _, key in ipairs(keys) do
    t[key] = nil
  end
  return t
end

function yatm_core.table_key_of(t, expected_value)
  for key,value in pairs(t) do
    if value == expected_value then
      return key
    end
  end
  return nil
end

function yatm_core.table_reduce(tbl, acc, fun)
  local should_break
  for k, v in pairs(tbl) do
    acc, should_break = fun(k, v, acc)
    if should_break then
      break
    end
  end
  return acc
end

function yatm_core.table_length(tbl)
  return yatm_core.table_reduce(tbl, 0, function (_k, _v, acc)
    return acc + 1
  end)
end

--
-- Create-And-Push
-- @mutative
-- @spec yatm_core.table_cpush(t: Table, key: String, value: term) :: Table
function yatm_core.table_cpush(t, key, value)
  if not t[key] then
    t[key] = {}
  end
  table.insert(t[key], value)
  return t
end

--
-- Used to merge multiple map-like tables together, if you need to merge lists
-- use `list_concat/*` instead
--
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

-- @mutative
-- @spec yatm_core.table_put(t: Table, k: String, v: term) :: Table
function yatm_core.table_put(t, k, v)
  t[k] = v
  return t
end

-- Puts a value nested into a table
--
-- @mutative
-- @spec table_bury(table, keys :: [string | integer], value :: term) :: Table
function yatm_core.table_bury(t, keys, value)
  local top = t
  for i = 1,(#keys - 1) do
    if not top[keys[i]] then
      top[keys[i]] = {}
    end
    top = top[keys[i]]
  end
  top[keys[#keys]] = value
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
