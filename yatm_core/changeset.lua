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
  local changeset = {
    data = record,
    changes = {},
    is_valid = true,
    errors = {},
  }
  setmetatable(changeset, {__index = Changeset})
  return changeset
end

function Changeset:put_change(key, value)
  self.changes[key] = value
  return self
end

function Changeset:get_change(key)
  return self.changes[key]
end

function Changeset:get_field(key)
  return self.changes[key] or self.data[key]
end

function Changeset:cast(params, schema)
  for key,value in pairs(params) do
    if schema[key] then
      local casted_value = Changeset.Types[schema[key].type]
      self:put_change(key, casted_value)
    end
  end
  return self
end

function Changeset:clear_all_errors()
  self.errors = {}
  return self
end

function Changeset:add_error(key, value)
  self.errors[key] = self.errors[key] or {}
  table.insert(self.errors[key], value)
  self.is_valid = false
  return self
end

function Changeset:validate_change(key, validator)
  if self.changes[key] then
    local value = self.changes[key]
    local errors = validator(key, value)
    if errors then
      for key, value in pairs(errors) do
        self:add_error(key, value)
      end
    end
  end
  return self
end

function Changeset:validate_required(keys)
  for _,key in ipairs(keys) do
    if self.changes[key] or self.data[key] then
      -- All is well here
    else
      self:add_error(key, "required")
    end
  end
  return self
end

yatm_core.Changeset = Changeset
