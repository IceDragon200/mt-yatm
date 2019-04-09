local function get_solid_fuel_heater_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    "list[nodemeta:" .. spos .. ";fuel_slot;0,0.3;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";fuel_slot]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

local function solid_fuel_heater_on_construct(pos)
  yatm.devices.device_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("fuel_slot", 1)
end,

local function solid_fuel_heater_on_rightclick(pos, node, clicker)
  minetest.show_formspec(
    clicker:get_player_name(),
    "yatm_foundry:solid_fuel_heater",
    get_solid_fuel_heater_formspec(pos)
  )
end

local function solid_fuel_heater_allow_metadata_inventory_put(pos, listname, index, item_stack, player)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  -- The slot should be the fuel slot, I mean it's the only slot there.

  local teststack = ItemStack(stack)
  teststack:set_count(1)

  local output, decremented_input = minetest.get_craft_result({method="fuel", width=1, items={teststack}})

  if replace_item:is_empty() then
    -- For most fuels, just allow to place everything
    return stack:get_count()
  else
    if inv:get_stack(listname, index):get_count() == 0 then
      return 1
    else
      return 0
    end
  end
end

local function solid_fuel_heater_on_metadata_inventory_put(pos, listname, index, item_stack, player)
  minetest.get_node_timer(pos):start(1.0)
end

local function solid_fuel_heater_node_timer(pos, elapsed)
  local meta = minetest.get_meta(pos)
  local fuel_time = meta:get_float("fuel_time") or 0
  local fuel_totaltime = meta:get_float("fuel_totaltime") or 0
  if fuel_time > 0 then
    meta:set_float("fuel_time", fuel_time - elapsed)
    return true
  else
    local fuellist = inv:get_list("fuel")
    local fuel, afterfuel = minetest.get_craft_result({method="fuel", width=1, items=fuellist})
    if fuel.time == 0 then
      meta:set_float("fuel_time", 0)
      meta:set_float("fuel_totaltime", 0)

      minetest.swap_node(pos, {name = "yatm_foundry:solid_fuel_heater_off"})
      return false
    else
      inv:set_stack("fuel", 1, afterfuel.items[1])

      meta:set_float("fuel_time", fuel.time)
      meta:set_float("fuel_totaltime", fuel.time)

      minetest.swap_node(pos, {name = "yatm_foundry:solid_fuel_heater_on"})
      return true
    end
  end
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

local node_box = {
  type = "fixed",
  fixed = {
    {-0.5, (4 / 16) - 0.5, -0.5, 0.5, 0.5, 0.5},
    {(1 / 16) - 0.5, -0.5, (1 / 16) -0.5, (15 / 16) - 0.5, (4 / 16) - 0.5, (15 / 16) - 0.5},
  }
}

minetest.register_node("yatm_foundry:solid_fuel_heater_off", {
  description = "Solid Fuel Heater",
  groups = groups,
  tiles = {
    "yatm_solid_fuel_heater_top.off.png",
    "yatm_solid_fuel_heater_bottom.off.png",
    "yatm_solid_fuel_heater_side.off.png",
    "yatm_solid_fuel_heater_side.off.png^[transformFX",
    "yatm_solid_fuel_heater_side.off.png",
    "yatm_solid_fuel_heater_side.off.png"
  },
  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),

  on_construct = solid_fuel_heater_on_construct,
  on_rightclick = solid_fuel_heater_on_rightclick,
  on_timer = solid_fuel_heater_node_timer,

  allow_metadata_inventory_put = solid_fuel_heater_allow_metadata_inventory_put,
  on_metadata_inventory_put = solid_fuel_heater_on_metadata_inventory_put,
})

minetest.register_node("yatm_foundry:solid_fuel_heater_on", {
  description = "Solid Fuel Heater",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  tiles = {
    "yatm_solid_fuel_heater_top.on.png",
    "yatm_solid_fuel_heater_bottom.on.png",
    "yatm_solid_fuel_heater_side.on.png",
    "yatm_solid_fuel_heater_side.on.png^[transformFX",
    "yatm_solid_fuel_heater_side.on.png",
    "yatm_solid_fuel_heater_side.on.png"
  },
  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),

  on_construct = solid_fuel_heater_on_construct,
  on_rightclick = solid_fuel_heater_on_rightclick,
  on_timer = solid_fuel_heater_node_timer,

  allow_metadata_inventory_put = solid_fuel_heater_allow_metadata_inventory_put,
  on_metadata_inventory_put = solid_fuel_heater_on_metadata_inventory_put,
})
