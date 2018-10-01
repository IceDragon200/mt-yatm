--[[
A general registry for all things measurable, that includes fluids,
gases and whatever else I feel like throwing in here.
]]

local m = {
  members = {},
  group_members = {},
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

function m.register_item(name, def)
  def.groups = def.groups or {}
  m.members[name] = def
  for group,_weight in pairs(def.groups) do
    m.group_members[group] = name
  end
  return def
end

function m.members_of(group_name)
  return m.group_members[group_name] or {}
end

function m.is_member_of(name, group_name)
  local member = m.members[name]
  if member then
    return member.groups[group_name] ~= nil
  end
  return false
end

function m.get_measurable(meta, key)
  return m:get(meta, key)
end

function m.set_measurable(meta, key, params)
  m:set(meta, key, params)
  return meta
end

function m.get_measurable_name(meta, key)
  return m:get_field(meta, key, "name")
end

function m.set_measurable_name(meta, key, name)
  -- need a name and it shouldn't be empty
  if name and name ~= "" then
    assert(m.members[name], "expected measurable to exist " .. name)
    m:set_field(meta, key, "name", name)
  else
    m:set_field(meta, key, "name", "")
  end
  return meta
end

function m.get_measurable_amount(meta, key)
  return m:get_field(meta, key, "amount")
end

function m.set_measurable_amount(meta, key, amount)
  m:set_field(meta, key, "amount")
  return meta
end

yatm_core.measurable = m
