local ByteBuf = yatm_core.ByteBuf

local BinSchema = yatm_core.Class:extends("BinSchema")
local ic = BinSchema.instance_class

--[[
@type IType.t :: {
  write(self, file, data) :: (bytes_written :: non_neg_integer, error)
  read(self, file) :: (any, bytes_read :: non_neg_integer)
}

@type scalar_type ::
  "u8" |
  "u16" |
  "u24" |
  "u32" |
  "i8" |
  "i16" |
  "i24" |
  "i32" |
  "f16" |
  "f24" |
  "f32" |
  "f64" |
  "u8bool" |
  "u8string" |
  "u16string" |
  "u24string" |
  "u32string"

@type element_type :: scalar_type | IType.t
@type definition :: [
  non_neg_integer | -- Padding
  {name :: String, "*array", element_type} | -- Variable length array
  {name :: String, "array", element_type, length :: non_neg_integer} | -- Fixed length array
  {name :: String, "map", key_type, value_type} | -- Map
  {name :: String, element_type} | -- Any other type
]
@spec initialize(String, definition) :: void
]]
function ic:initialize(name, definition)
  ic._super.initialize(self)
  assert(definition, "expected a definition list")

  self.m_name = assert(name)
  self.m_definition = yatm_core.list_map(definition, function (element)
    if type(element) == "number" then
      return {type = 0, length = element}
    elseif type(element) == "table" then
      local name = element[1]
      local t = element[2]
      assert(t, "expected a type")
      if type(t) == "string" then
        -- variable length array
        if t == "*array" then
          local value_type = element[3]
          assert(value_type, "expected a value_type")
          return {name = name, type = yatm_core.binary_types.Array:new(value_type, -1)}
        -- fixed length array
        elseif t == "array" then
          local value_type = element[3]
          assert(value_type, "expected a value_type")
          local len = element[4]
          assert(len, "expected a length")
          return {name = name, type = yatm_core.binary_types.Array:new(value_type, len)}
        elseif t == "map" then
          local kt = element[3]
          assert(kt, "expected a key type")
          local vt = element[4]
          assert(vt, "expected a value type")
          return {name = name, type = yatm_core.binary_types.Map:new(kt, vt)}
        elseif yatm_core.binary_types.Scalars[t] then
          return {name = name, type = yatm_core.binary_types.Scalars[t]}
        else
          error("unexpected type " .. t)
        end
      elseif type(t) == "table" then
        assert(t.write, name .. "; expected write/3")
        assert(t.read, name .. "; expected write/2")
        assert(t.size, name .. "; expected size/0")
        return {name = name, type = t}
      else
        error("expected a named type or type table")
      end
    else
      error("expected a number or table")
    end
  end)
end

function ic:size()
  return yatm_core.list_reduce(self.m_definition, 0, function (block, current_size)
    -- Padding
    if block.type == 0 then
      return current_size + block.length
    else
      if block.type.size then
        return current_size + block.type:size()
      else
        error("field " .. block.name .. "; type has no `size` function")
      end
    end
  end)
end

function ic:write(stream, data)
  return yatm_core.list_reduce(self.m_definition, 0, function (block, all_bytes_written)
    if block.type == 0 then
      for _ = 1,block.length do
        local bytes_written, err = ByteBuf.w_u8(stream, 0)
        all_bytes_written = all_bytes_written + bytes_written
        if err then
          error(err)
        end
      end
    else
      local item = data[block.name]
      local bytes_written, err = block.type:write(stream, item)
      all_bytes_written = all_bytes_written + bytes_written
      if err then
        error(err)
      end
    end
    return all_bytes_written
  end), nil
end

function ic:read(stream, target)
  target = target or {}
  return target, yatm_core.list_reduce(self.m_definition, 0, function (block, all_bytes_read)
    if block.type == 0 then
      local _, bytes_read = ByteBuf.read(stream, block.length)
      all_bytes_read = all_bytes_read + bytes_read
    else
      print("debug", "BinSchema", self.m_name, "reading field", block.name, "at pos", stream:tell())
      local value, bytes_read = block.type:read(stream)
      all_bytes_read = all_bytes_read + bytes_read
      target[block.name] = value
      print("debug", "BinSchema", self.m_name, "read field", block.name)
    end
    return all_bytes_read
  end)
end

yatm_core.BinSchema = BinSchema
