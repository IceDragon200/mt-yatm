--[[
A general registry for all things measurable, that includes fluids,
gases and whatever else I feel like throwing in here.
]]

local m = {
}

m.schema = yatm_core.MetaSchema.new("measurable", "", {
  name = {
    type = "string"
  },

  amount = {
    -- so... why integer?
    -- floats are a pain in the ass, that's why.
    type = "integer"
  }
})

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

--[[
Retrieve a list of the members in the specified group
]]
function m.members_of(registry, group_name)
  return registry.group_members[group_name] or {}
end

function m.is_member_of(registry, name, group_name)
  local member = registry.members[name]
  if member then
    return member.groups[group_name] ~= nil
  end
  return false
end

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

yatm_core.measurable = m
