local FakeMetaRef = {
  instance_class = {}
}

function FakeMetaRef.new(...)
  local metaref = {}
  setmetatable(metaref, { __index = FakeMetaRef.instance_class })
  metaref:initialize(...)
  return metaref
end

--[[

* `contains(key)`: Returns true if key present, otherwise false.
    * Returns `nil` when the MetaData is inexistent.
* `get(key)`: Returns `nil` if key not present, else the stored string.
* `set_string(key, value)`: Value of `""` will delete the key.
* `get_string(key)`: Returns `""` if key not present.
* `set_int(key, value)`
* `get_int(key)`: Returns `0` if key not present.
* `set_float(key, value)`
* `get_float(key)`: Returns `0` if key not present.
* `to_table()`: returns `nil` or a table with keys:
    * `fields`: key-value storage
    * `inventory`: `{list1 = {}, ...}}` (NodeMetaRef only)
* `from_table(nil or {})`
    * Any non-table value will clear the metadata
    * See [Node Metadata] for an example
    * returns `true` on success
* `equals(other)`
    * returns `true` if this metadata has the same key-value pairs as `other`

]]
local c = FakeMetaRef.instance_class

function c:initialize(data)
  self.data = data or {}
end

function c:contains(key)
  return self.data[key] ~= nil
end

function c:get(key)
  return self.data[key]
end

function c:set_string(key, value)
  self.data[key] = tostring(value)
  return self
end

function c:get_string(key)
  return tostring(self.data[key])
end

function c:set_int(key, value)
  self.data[key] = math.floor(tonumber(value))
  return self
end

function c:get_int(key)
  return math.floor(tonumber(self.data[key]))
end

function c:set_float(key, value)
  self.data[key] = tonumber(value) * 1.0
  return self
end

function c:get_float(key)
  return tonumber(self.data[key]) * 1.0
end

function c:to_table()
  return table.copy(self.data)
end

function c:from_table(value)
  if type(value) == "table" then
    -- TODO: lint the values in the table
    self.data = value
  else
    self.data = {}
  end
  return self
end

function c:equals(other)
  return yatm_core.table_equals(self.data, other)
end

yatm_core.FakeMetaRef = FakeMetaRef
