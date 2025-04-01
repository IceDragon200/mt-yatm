local Color = assert(foundation.com.Color)
local assertions = assert(foundation.com.assertions)
local fspec = assert(foundation.com.formspec.api)
-- local string_split = assert(foundation.com.string_split)

--- @namespace yatm.devices.upgrades
yatm.devices.upgrades = yatm.devices.upgrades or {}

local m = yatm.devices.upgrades

--- The inventory list name used for upgrades, machines don't really need to manage it.
---
--- @const UPGRADE_SLOT: String
m.UPGRADE_SLOT = "upgrade_slot"

--- The header schema is used on the machine to inform us of how many upgrades unique are present on a
--- machine.
---
--- @const UpgradeHeaderSchema: CompiledMetaSchema
m.UpgradeHeaderSchema = foundation.com.MetaSchema:new(
  "UpgradeHeaderSchema",
  "",
  {
    count = {
      type = "integer"
    }
  }
):compile("uhds")

--- The UpgradeSchema represents any single unique upgrade present on a machine.
---
--- @const UpgradeSchema: MetaSchema
m.UpgradeSchema = foundation.com.MetaSchema:new(
  "UpgradeSchema",
  "",
  {
    --- ID corresponds to the name of the upgrade
    id = {
      type = "string"
    },
    --- Count is how many instances of the upgrade are currently installed
    count = {
      type = "integer"
    },
  }
)

--- @const registered_upgrades: Table
m.registered_upgrades = m.registered_upgrades or {}

--- @const upgrades_by_group: {
---   [group_name: String]: {
---     [upgrade_name: String]: Integer
---   }
--- }
m.upgrades_by_group = m.upgrades_by_group or {}

--- @spec register_upgrade(name: String, def: Table): void
function m.register_upgrade(name, def)
  assertions.is_table(def)

  def.name = assertions.is_string(name)
  def.groups = assertions.is_table(def.groups or {})
  def.max_count = def.max_count or 100

  m.registered_upgrades[def.name] = def

  for group_name,value in pairs(def.groups) do
    if not m.upgrades_by_group[group_name] then
      m.upgrades_by_group[group_name] = {}
    end
    m.upgrades_by_group[group_name][name] = value
  end
end

--- @spec set_upgrade_data(meta: MetaRef, index: Integer, params: Table): void
function m.set_upgrade_data(meta, index, params)
  m.UpgradeSchema:set(meta, "upg"..index, params)
end

--- @spec get_upgrade_data(meta: MetaRef, index: Integer): Table
function m.get_upgrade_data(meta, index)
  return m.UpgradeSchema:get(meta, "upg"..index)
end

--- @spec get_upgrade_data_field(meta: MetaRef, index: Integer, field: String): Any
function m.get_upgrade_data_field(meta, index, field)
  return m.UpgradeSchema:get_field(meta, "upg"..index, field)
end

--- @spec find_upgrade_data_by_id(meta: MetaRef, id: String): (index: Integer, data: Table)
function m.find_upgrade_data_by_id(meta, id)
  local upgrades_count = m.UpgradeHeaderSchema:get_count(meta)
  local upgrade_id
  for index = 1,upgrades_count do
    upgrade_id = get_upgrade_data_field(meta, index, "id")
    if upgrade_id == id then
      return index, m.get_upgrade_data(meta, index)
    end
  end
  return nil, nil
end

--- @spec calculate_stat(
---   stat: String,
---   pos: Vector3,
---   node: NodeRef,
---   meta: MetaRef,
---   base: Number
--- ): Number
function m.calculate_stat(stat, pos, node, meta, base)
  local upgrades_count = m.UpgradeHeaderSchema:get_count(meta)
  local result = base
  if upgrades_count > 0 then
    local upgrade_data
    local upgrade_entry

    for index = 1,upgrades_count do
      upgrade_data = m.get_upgrade_data(meta, index)
      upgrade_entry = m.registered_upgrades[upgrade_data.id]
      if upgrade_entry then
        if upgrade_entry.stats then
          if upgrade_entry.stats[stat] then
            result = upgrade_entry.stats[stat](upgrade_data, pos, node, meta, result)
          end
        end
      end
    end
  end
  return result
end

---
--- @spec initialize_upgrade_slots(meta: MetaRef): void
function m.initialize_upgrade_slots(meta)
  local inv = meta:get_inventory()
  inv:set_size(m.UPGRADE_SLOT, 1)
end

---
--- @spec render_upgrades_formspec(pos: Vector3, user: PlayerRef, state: Table): String
function m.render_upgrades_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = core.get_meta(pos)

  local upgrades_count = m.UpgradeHeaderSchema:get_count(meta)

  local background_color = Color.new(64, 66, 64)

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      local formspec = ""
      if upgrades_count > 0 then
        local upgrade_data
        local upgrade_entry
        local itemdef
        local y
        for index = 1,upgrades_count do
          upgrade_data = m.get_upgrade_data(meta, index)
          upgrade_entry = m.registered_upgrades[upgrade_data.id]
          y = rect.y + cio(index - 1)
          if upgrade_entry then
            itemdef = core.registered_items[upgrade_entry.item]
            formspec =
              formspec
              .. fspec.box(rect.x, y, cis(4), cis(1), background_color)
              .. fspec.item_image(rect.x, y, cis(1), cis(1), upgrade_entry.item)
              -- TODO: description may need to be split to extract only the first line
              .. fspec.text(rect.x, y, itemdef.description)
              .. fspec.list(node_inv_name, UPGRADE_SLOT, rect.x + cio(4), rect.y, 1, 1)
              .. fspec.button(
                rect.x + cio(4), rect.y + cio(1),
                cis(4), cis(1),
                "apply_upgrade",
                "Upgrade"
              )
          end
        end
      end
      return formspec
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

--- @spec on_receive_fields_upgrades(
---   player: PlayerRef,
---   form_name: String,
---   fields: Table,
---   state: Table
--- ): (stop_bubbling: Boolean, formspec: String)
function m.on_receive_fields_upgrades(player, form_name, fields, state)
  if fields["apply_upgrade"] then
    local meta = core.get_meta(state.pos)

    local inv = meta:get_inventory()
    local stack = inv:get_stack(m.UPGRADE_SLOT, 1)
    if not stack:is_empty() then
      local leftover = m.install_upgrade_from_item_stack(state.pos, state.node, stack)
      inv:set_stack(m.UPGRADE_SLOT, 1, leftover)
    end
  end
  return false, nil
end

--- @spec install_upgrade_from_item_stack(
---   pos: Vector3,
---   node: NodeRef,
---   stack: ItemStack
--- ): (leftover: ItemStack)
function m.install_upgrade_from_item_stack(pos, node, stack)
  local meta = core.get_meta(pos)

  if not stack:is_empty() then
    local def = stack:get_definition()

    local yatm_upgrade = def.yatm_upgrade

    if yatm_upgrade then
      -- attempt to find an existing upgrade
      local index, upgrade_data = m.find_upgrade_data_by_id(meta, yatm_upgrade.id)
      if not index then
        -- if none is present, then take the current count, increment it and write it back
        index = m.UpgradeHeaderSchema:get_count(meta) + 1
        m.UpgradeHeaderSchema:set_count(meta, index)
        upgrade_data = {
          id = yatm_upgrade.id,
          count = 0,
        }
      end
      -- use the item's upgrade id, not thhe upgrade_data, since that may be nil
      local upgrade = assert(m.registered_upgrades[upgrade_data.id])

      local old_count = upgrade_data.count
      upgrade_data.count = upgrade_data.count + stack:get_count()
      upgrade_data.count = math.min(upgrade_data.count, upgrade.max_count)
      local used_count = upgrades_count - old_count

      stack:take_item(used_count)

      m.set_upgrade_data(meta, index, upgrade_data)
    end
  end

  return stack
end
