--[[
Structured metadata, because sometimes you need to know just what the f*** you're doing

Optionally, the MetaSchema can be compiled with a fixed name to reduce some of the overhead
]]
local MetaSchema = yatm_core.Class:extends()

MetaSchema.Vec2 = {
  type = "schema",
  schema = {
    x = { type = "float" },
    y = { type = "float" },
  },
}

MetaSchema.Vec3 = {
  type = "schema",
  schema = {
    x = { type = "float" },
    y = { type = "float" },
    z = { type = "float" },
  },
}

MetaSchema.Vec4 = {
  type = "schema",
  schema = {
    x = { type = "float" },
    y = { type = "float" },
    z = { type = "float" },
    w = { type = "float" },
  },
}

local m = assert(MetaSchema.instance_class)
-- Create a new kind of buffer
--
function m:initialize(name, prefix, schema)
  -- The name is used to help identify the buffer type
  self.name = name
  -- A string to prefix any fields in the schema with when writing.
  self.prefix = prefix
  self.type = "schema"
  self.schema = schema
end

function make_setter(entry, field_name)
  if entry.type == "string" then
    return function (self, meta, value)
      meta:set_string(field_name, value)
      return self
    end
  elseif entry.type == "number" or entry.type == "float" then
    return function (self, meta, value)
      meta:set_float(field_name, value)
      return self
    end
  elseif entry.type == "integer" then
    return function (self, meta, value)
      meta:set_int(field_name, value)
      return self
    end
  else
    error("unhandled setter of type " .. dump(entry.type))
  end
end

function make_getter(entry, field_name)
  if entry.type == "string" then
    return function (self, meta)
      return meta:get_string(field_name)
    end
  elseif entry.type == "number" or entry.type == "float" then
    return function (self, meta)
      return meta:get_float(field_name)
    end
  elseif entry.type == "integer" then
    return function (self, meta)
      return meta:get_int(field_name)
    end
  else
    error("unhandled setter of type " .. dump(entry.type))
  end
end

--[[
Compiles a given meta schema with a fixed basename

The returned schema will have getters and setters of their entries.

Args:
* `basename` - a basename to give the field names

Returns:
* Compiled schema
]]
function m:compile(basename)
  assert(basename, "expected a basename")
  local schema = {
    keys = {}
  }

  local prefix = (self.prefix or "") .. basename
  for key, entry in pairs(self.schema) do
    local field_name = prefix .. "_" .. key
    local setter_name = "set_" .. key
    local getter_name = "get_" .. key
    schema[key] = {
      field_name = field_name,
      type = entry.type,
      setter_name = setter_name,
      getter_name = getter_name,
    }

    if entry.type == "schema" then
      local sub_schema = entry.schema:compile(field_name)
      sub_schema["schema_" .. key] = sub_schema
      schema[setter_name] = function (self, meta, value)
        sub_schema:set(meta, value)
        return self
      end
      schema[getter_name] = function (self, meta)
        return sub_schema:get()
      end
    else
      schema[setter_name] = make_setter(entry, field_name)
      schema[getter_name] = make_getter(entry, field_name)
    end
  end

  function schema.set(self, meta, t)
    for key,value in pairs(t) do
      local entry = schema.keys[key]
      if entry then
        self[entry.setter_name](self, meta, value)
      end
    end
    return self
  end

  function schema.get(self, meta)
    local result = {}
    for key,entry in pairs(self.keys) do
      result[key] = self[entry.getter_name](self, meta)
    end
    return result
  end

  return schema
end

--[[
Args:
* `meta` - a NodeMetaRef
* `buffer` - a buffer instance
]]
function m:set_field(meta, basename, key, value)
  assert(meta, "expected a meta")
  if self.schema[key] then
    local entry = self.schema[key]
    local field_name = (self.prefix or "") .. basename .. "_" .. key

    if entry.type == "string" then
      meta:set_string(field_name, value)
    elseif entry.type == "number" then
      meta:set_float(field_name, value)
    elseif entry.type == "integer" then
      meta:set_int(field_name, value)
    elseif entry.type == "float" then
      meta:set_float(field_name, value)
    elseif entry.type == "schema" then
      entry.schema:set(meta, field_name, value)
    end
  end
end

function m:set(meta, basename, params)
  assert(meta, "expected a metaref")
  for key,value in pairs(params) do
    self:set_field(meta, basename, key, value)
  end
end

function m:get_field(meta, basename, key)
  assert(meta, "expected a metaref")
  if self.schema[key] then
    local entry = self.schema[key]
    local field_name = (self.prefix or "") .. basename .. "_" .. key

    if entry.type == "string" then
      return meta:get_string(field_name)
    elseif entry.type == "number" then
      return meta:get_float(field_name)
    elseif entry.type == "integer" then
      return meta:get_int(field_name)
    elseif entry.type == "float" then
      return meta:get_float(field_name)
    elseif entry.type == "schema" then
      return entry.schema:get(meta, field_name)
    end
  end
  return nil
end

function m:get(meta, basename)
  assert(meta, "expected a meta")
  assert(basename, "expected a basename")
  local result = {}
  for key,_ in pairs(self.schema) do
    result[key] = self:get_field(meta, basename, key)
  end
  return result
end

yatm_core.MetaSchema = MetaSchema
