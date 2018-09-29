--[[
If you've ever used Elixir's Ecto, then you know what this is.
]]
local Changeset = {}

Changeset.Types = {
  number = {},
  integer = {},
  float = {},
  string = {},
  map = {},
  array = {},
}

Changeset.Types.number.cast = tonumber
Changeset.Types.integer.cast = function (value) return math.floor(tonumber(value)) end
Changeset.Types.float.cast = tonumber
Changeset.Types.string.cast = tostring
Changeset.Types.map.cast = function (value)
  return value
end
Changeset.Types.array.cast = function (value)
  return value
end

function Changeset.change(record)
  return {
    data = record,
    changes = {},
    is_valid = true,
    errors = {},
  }
end

function Changeset.put_change(changeset, key, value)
  changeset.changes[key] = value
  return changeset
end

function Changeset.get_change(changeset, key)
  return changeset.changes[key]
end

function Changeset.get_field(changeset, key)
  return changeset.changes[key] or changeset.data[key]
end

function Changeset.cast(changeset, params, schema)
  for key,value in pairs(params) do
    if schema[key] then
      local casted_value = Changeset.types[schema[key].type]
      changeset = Changeset.put_change(changeset, key, casted_value)
    end
  end
  return changeset
end

function Changeset.clear_all_errors(changeset)
  changeset.errors = {}
  return changeset
end

function Changeset.add_error(changeset, key, value)
  changeset.errors[key] = changeset.errors[key] or {}
  table.insert(changeset.errors[key], value)
  changeset.is_valid = false
  return changeset
end

function Changeset.validate_change(changeset, key, validator)
  if changeset.changes[key] then
    local value = changeset.changes[key]
    local errors = validator(key, value)
    if errors then
      for key, value in pairs(errors) do
        Changeset.add_error(changeset, key, value)
      end
    end
  end
  return changeset
end

function Changeset.validate_required(changeset, keys)
  for _,key in ipairs(keys) do
    if changeset.changes[key] or changeset.data[key] then
      -- All is well here
    else
      changeset = Changeset.add_error(changeset, key, "required")
    end
  end
  return changeset
end

yatm_core.Changeset = Changeset
