--[[

  A general registry for all things measurable, that includes fluids,
  gases and whatever else I feel like throwing in here.

]]

-- @namespace yatm.Measurable

-- @type ReducerFunction: function(name: String, member: Table, acc: Any) => (continue: Boolean, acc: Any)

local m = {
}

m.schema = foundation.com.MetaSchema:new("measurable", "", {
  name = {
    type = "string"
  },

  amount = {
    -- so... why integer?
    -- floats are a pain in the ass, that's why.
    type = "integer"
  }
})

-- @spec register(Registry, name: String, def: Table): (def: Table)
function m.register(registry, name, def)
  assert(registry, "expected a registry")
  assert(name, "requires a name")
  assert(def, "requires a definition")
  def.groups = def.groups or {}
  def.safe_name = string.gsub(name, ":", "_")
  def.registered_by = minetest.get_current_modname()
  registry.members = registry.members or {}
  registry.group_members = registry.group_members or {}
  registry.members[name] = def
  registry.aliases = registry.aliases or {}
  if def.aliases then
    for _,alias in ipairs(def.aliases) do
      registry.aliases[alias] = name
      print("Measurable", "register", "aliasing", dump(alias), "to", dump(name))
    end
  end
  for group,value in pairs(def.groups) do
    registry.group_members[group] = registry.group_members[group] or {}
    registry.group_members[group][name] = value
  end
  return def
end

-- Retrieve a table of the members in the specified group
--
-- @spec member_of(Registry, group_name: String): { [name: String]: Integer }
function m.members_of(registry, group_name)
  return registry.group_members[group_name] or {}
end

-- @spec is_member_of(Registry, name: String, group_name: String): Boolean
function m.is_member_of(registry, name, group_name)
  local member = registry.members[name]
  if member then
    return member.groups[group_name] ~= nil
  end
  return false
end

-- @spec reduce_members_of(Registry, group_name: String, acc: Any, reducer: ReducerFunction): (acc: Any)
function m.reduce_members_of(registry, group_name, acc, fun)
  local base = registry.group_members[group_name];
  if base then
    local con
    for name,_ in pairs(base) do
      con, acc = fun(name, registry.members[name], acc)
      if not con then
        break
      end
    end
  end
  return acc
end

function m.get_measurable(meta, key)
  return m.schema:get(meta, key)
end

function m.set_measurable(meta, key, params)
  m.schema:set(meta, key, params)
  return meta
end

function m.get_measurable_name(meta, key)
  return m.schema:get_field(meta, key, "name")
end

-- @spec set_measurable_name(FluidRegistry, MetaRef, key: String, name: String): MetaRef
function m.set_measurable_name(registry, meta, key, name)
  assert(registry, "expected registry")
  assert(meta, "expected metadata")
  -- need a name and it shouldn't be empty
  if name and name ~= "" then
    name = registry.aliases[name] or name
    assert(registry.members[name], "expected measurable to exist " .. name)
    m.schema:set_field(meta, key, "name", name)
  else
    m.schema:set_field(meta, key, "name", "")
  end
  return meta
end

function m.get_measurable_amount(meta, key)
  return m.schema:get_field(meta, key, "amount")
end

function m.set_measurable_amount(meta, key, amount)
  m.schema:set_field(meta, key, "amount", amount)
  return meta
end

yatm.Measurable = m
