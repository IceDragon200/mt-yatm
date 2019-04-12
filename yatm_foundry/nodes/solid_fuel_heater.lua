local ItemInterface = assert(yatm.items.ItemInterface)

local function is_item_solid_fuel(item_stack)
  if not item_stack or item_stack:get_count() == 0 then
    return false
  end
  local ingredient_stack = ItemStack(item_stack)
  ingredient_stack:set_count(1)

  local recipe, decremented_input = minetest.get_craft_result({
    method = "fuel",
    width = 1,
    items = { ingredient_stack }
  })

  return recipe.time > 0
end

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
end

local function solid_fuel_heater_on_rightclick(pos, node, clicker)
  minetest.show_formspec(
    clicker:get_player_name(),
    "yatm_foundry:solid_fuel_heater",
    get_solid_fuel_heater_formspec(pos)
  )
end

local function solid_fuel_heater_allow_metadata_inventory_put(pos, listname, index, item_stack, player)
  if is_item_solid_fuel(item_stack) then
    return item_stack:get_count()
  else
    return 0
  end
end

local function solid_fuel_heater_on_metadata_inventory_put(pos, listname, index, item_stack, player)
  minetest.get_node_timer(pos):start(1.0)
end

local function solid_fuel_heater_node_timer(pos, elapsed)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local fuel_time = meta:get_float("fuel_time") or 0
  local fuel_time_max = meta:get_float("fuel_time_max") or 0
  local heat = meta:get_float("heat") or 0

  if fuel_time > 0 then
    meta:set_float("fuel_time", fuel_time - elapsed)
    meta:set_float("heat", math.min(heat + 10 * elapsed, 1600))

    yatm_core.queue_refresh_infotext(pos)
    return true
  else
    local fuel_list = inv:get_list("fuel_slot")
    local fuel, afterfuel = minetest.get_craft_result({
      method = "fuel",
      width = 1,
      items = fuel_list
    })
    if fuel.time > 0 then
      inv:set_stack("fuel_slot", 1, afterfuel.items[1])

      meta:set_float("fuel_time", fuel.time)
      meta:set_float("fuel_time_max", fuel.time)

      minetest.swap_node(pos, {name = "yatm_foundry:solid_fuel_heater_on"})
      yatm_core.queue_refresh_infotext(pos)
      return true
    else
      meta:set_float("fuel_time", 0)
      meta:set_float("fuel_time_max", 0)

      if heat > 0 then
        -- Heat dissipation logic - wow!
        meta:set_float("heat", math.max(heat - 5 * elapsed, 0))
        yatm_core.queue_refresh_infotext(pos)
        return true
      else
        minetest.swap_node(pos, {name = "yatm_foundry:solid_fuel_heater_off"})
        yatm_core.queue_refresh_infotext(pos)
        return false
      end
    end
  end
end

local function solid_fuel_heater_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local fuel_time = meta:get_float("fuel_time")
  local fuel_time_max = meta:get_float("fuel_time_max")

  local heat = math.floor(meta:get_float("heat"))

  meta:set_string("infotext",
    -- TODO: pull the max heat from configuration
    "Heat: " .. heat .. " / 1600" .. "\n" ..
    "Fuel Time: " .. yatm_core.format_pretty_time(fuel_time) .. " / " .. yatm_core.format_pretty_time(fuel_time_max)
  )
end

local solid_fuel_heater_item_interface = ItemInterface.new_simple("fuel_slot")

function solid_fuel_heater_item_interface:allow_insert_item(pos, dir, item_stack)
  if is_item_solid_fuel(item_stack) then
    return true
  else
    print("Cannot insert", minetest.pos_to_string(pos), yatm_core.inspect_axis(dir), yatm_core.itemstack_inspect(item_stack))
    return false, "item is not solid fuel"
  end
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  heater_device = 1,
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

  item_interface = solid_fuel_heater_item_interface,

  on_construct = solid_fuel_heater_on_construct,
  on_rightclick = solid_fuel_heater_on_rightclick,
  on_timer = solid_fuel_heater_node_timer,

  allow_metadata_inventory_put = solid_fuel_heater_allow_metadata_inventory_put,
  on_metadata_inventory_put = solid_fuel_heater_on_metadata_inventory_put,

  refresh_infotext = solid_fuel_heater_refresh_infotext,
  transfer_heat = assert(yatm.heating.default_transfer_heat),
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

  light_source = 7,

  sounds = default.node_sound_stone_defaults(),

  item_interface = solid_fuel_heater_item_interface,

  on_construct = solid_fuel_heater_on_construct,
  on_rightclick = solid_fuel_heater_on_rightclick,
  on_timer = solid_fuel_heater_node_timer,

  allow_metadata_inventory_put = solid_fuel_heater_allow_metadata_inventory_put,
  on_metadata_inventory_put = solid_fuel_heater_on_metadata_inventory_put,

  refresh_infotext = solid_fuel_heater_refresh_infotext,
  transfer_heat = assert(yatm.heating.default_transfer_heat),
})
