local TOML = {}

local function format_prefix(prefix)
  local result = {}
  for _, value in ipairs(prefix) do
    if string.match(value, "^[%w_]+$") then
      table.insert(result, value)
    else
      table.insert(result, "\"" .. value .. "\"")
    end
  end
  return table.concat(result, ".")
end

function TOML.encode_iodata(object, prefix, result)
  local result = result or {}

  local other_objects = {}
  -- in order to have some assertable data, keys are sorted
  local keys = yatm_core.table_keys(object)
  table.sort(keys)
  for _, key in ipairs(keys) do
    local value = object[key]
    local t = type(value)
    if t == "table" then
      other_objects[key] = value
    elseif t == "string" then
      table.insert(result, key .. " = \"" .. value .. "\"")
    elseif t == "number" then
      table.insert(result, key .. " = " .. value)
    elseif t == "boolean" then
      if value then
        table.insert(result, key .. " = true")
      else
        table.insert(result, key .. " = false")
      end
    else
      error("unexpected type " .. t)
    end
  end

  for key, value in pairs(other_objects) do
    if not prefix then
      prefix = {}
    end

    local current_prefix = yatm_core.table_copy(prefix)
    table.insert(current_prefix, key)
    table.insert(result, "[" .. format_prefix(current_prefix) .. "]")
    TOML.encode_iodata(value, current_prefix, result)
  end
  if result[#result] ~= "" then
    table.insert(result, "")
  end

  return result
end

function TOML.encode(object)
  return table.concat(TOML.encode_iodata(object), "\n")
end

function TOML.write(stream, object)
  local body = TOML.encode(object)

  stream:write(body)
end

yatm_core.TOML = TOML
