--[[

  If you've ever used Elixir's Ecto, then you know what this is.

]]
local Changeset = yatm_core.Class:extends("Changeset")

Changeset.Types = {
  number = {},
  integer = {},
  float = {},
  string = {},
  map = {},
  array = {},
}

function Changeset.Types.number.cast(value)
  return tonumber(value)
end

function Changeset.Types.integer.cast(value)
  return math.floor(tonumber(value))
end

function Changeset.Types.float.cast(value)
  return tonumber(value)
end

function Changeset.Types.string.cast(value)
  return tostring(value)
end

function Changeset.Types.map.cast(value)
  if type(value) == 'table' then
    return value
  else
    error("expected a table")
  end
end

function Changeset.Types.array.cast(value)
  if type(value) == 'table' then
    return value
  else
    error("expected a table")
  end
end

local ic = Changeset.instance_class

function ic:initialize(schema, record)
  self.schema = schema
  self.data = record or {}
  self.changes = {}
  self.is_valid = true
  self.errors = {}
end

function ic:has_errors()
  return not yatm_core.is_table_empty(self.errors)
end

function ic:apply_changes()
  for key,value in pairs(self.changes) do
    self.data[key] = value
  end
  return self.data
end

function ic:remove_change(key)
  self.changes[key] = nil
  return self
end

function ic:put_change(key, value)
  self.changes[key] = value
  return self
end

function ic:get_change(key)
  return self.changes[key]
end

function ic:get_field(key)
  return self.changes[key] or self.data[key]
end

function ic:cast(params, allowed)
  for _,key in ipairs(allowed) do
    local value = params[key]
    if self.schema[key] then
      local type_module = Changeset.Types[self.schema[key].type]
      local casted_value = type_module.cast(value)
      self:put_change(key, casted_value)
    end
  end
  return self
end

function ic:clear_all_errors()
  self.errors = {}
  return self
end

function ic:add_error(key, value)
  self.errors[key] = self.errors[key] or {}
  table.insert(self.errors[key], value)
  self.is_valid = false
  return self
end

function ic:validate_change(key, validator)
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

function ic:validate_required(keys)
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
