local ByteBuf = yatm_core.ByteBuf
local ArrayType = yatm_core.binary_types.Array
local MapType = yatm_core.binary_types.Map
local ScalarTypes = yatm_core.binary_types.Scalar

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
@spec initialize(definition) :: void
]]
function ic:initialize(definition)
  ic._super.initialize(self)
  assert(definition, "expected a definition list")
  self.definition = yatm_core.list_map(definition, function (element)
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
          return {name = name, type = ArrayType:new(value_type, -1)}
        -- fixed length array
        elseif t == "array" then
          local value_type = element[3]
          assert(value_type, "expected a value_type")
          local len = element[4]
          assert(len, "expected a length")
          return {name = name, type = ArrayType:new(value_type, len)}
        elseif t == "map" then
          local kt = element[3]
          assert(kt, "expected a key type")
          local vt = element[4]
          assert(vt, "expected a value type")
          return {name = name, type = MapType:new(kt, vt)}
        elseif ScalarTypes[t] then
          return {name = name, type = ScalarTypes[t]}
        else
          error("unexpected type " .. t)
        end
      elseif type(t) == "table" then
        assert(t.write, "expected write/3")
        assert(t.read, "expected write/2")
        return {name = name, type = t}
      else
        error("expected a named type or type table")
      end
    else
      error("expected a number or table")
    end
  end)
end

function ic:write(file, data)
  return yatm_core.list_reduce(self.definition, 0, function (block, all_bytes_written)
    if block.type == 0 then
      for _ = 1,block.length do
        local bytes_written, err = ByteBuf.w_u8(file, 0)
        all_bytes_written = all_bytes_written + bytes_written
        if err then
          error(err)
        end
      end
    else
      local item = data[block.name]
      local bytes_written, err = block.type:write(file, item)
      all_bytes_written = all_bytes_written + bytes_written
      if err then
        error(err)
      end
    end
    return all_bytes_written
  end), nil
end

function ic:read(file, target)
  target = target or {}
  return target, yatm_core.list_reduce(self.definition, 0, function (block, all_bytes_read)
    if block.type == 0 then
      local _, bytes_read = ByteBuf.read(file, block.length)
      all_bytes_read = all_bytes_read + bytes_read
    else
      print("BinSchema", "reading field", block.name)
      local value, bytes_read = block.type:read(file)
      all_bytes_read = all_bytes_read + bytes_read
      target[block.name] = value
    end
    return all_bytes_read
  end)
end

return BinSchema
