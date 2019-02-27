--[[
Structured meta data, because sometimes you need to know just what the f*** you're doing
]]
local MetaSchema = {}

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

-- Create a new kind of buffer
--
function MetaSchema.new(name, prefix, schema)
  local meta_schema = {
    -- The name is used to help identify the buffer type
    name = name,
    -- A string to prefix any fields in the schema with when writing.
    prefix = prefix,
    type = "schema",
    schema = schema,
  }
  setmetatable(meta_schema, {__index = MetaSchema})
  return meta_schema
end

--[[
Args:
* `meta` - a NodeMetaRef
* `buffer` - a buffer instance
]]
function MetaSchema:set_field(meta, basename, key, value)
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

function MetaSchema:set(meta, basename, params)
  assert(meta, "expected a meta")
  for key,value in pairs(params) do
    self:set_field(meta, basename, key, value)
  end
end

function MetaSchema:get_field(meta, basename, key)
  assert(meta, "expected a meta")
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
      return meta:set_float(field_name)
    elseif entry.type == "schema" then
      entry.schema:get(meta, field_name)
    end
  end
  return nil
end

function MetaSchema:get(meta, basename)
  assert(meta, "expected a meta")
  local result = {}
  for key,_ in pairs(self.schema) do
    result[key] = self:get_field(meta, basename, key)
  end
  return result
end

yatm_core.MetaSchema = MetaSchema
