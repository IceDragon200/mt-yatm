local table_merge = assert(foundation.com.table_merge)
local itemstack_inspect = assert(foundation.com.itemstack_inspect)
local format_pretty_time = assert(foundation.com.format_pretty_time)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local inspect_axis = assert(foundation.com.Directions.inspect_axis)
local cluster_thermal = assert(yatm.cluster.thermal)
local ItemInterface = assert(yatm.items.ItemInterface)

local function is_item_solid_fuel(item_stack)
  if not item_stack or item_stack:get_count() == 0 then
    return false
  end
  local ingredient_stack = ItemStack(item_stack)
  ingredient_stack:set_count(1)

  local recipe, decremented_input =
    minetest.get_craft_result({
      method = "fuel",
      width = 1,
      items = { ingredient_stack }
    })

  return recipe.time > 0
end

local function get_solid_fuel_heater_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine_heated") ..
    "list[nodemeta:" .. spos .. ";fuel_slot;0,0.3;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";fuel_slot]" ..
    "listring[current_player;main]"

  return formspec
end

local function solid_fuel_heater_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("fuel_slot", 1)

  cluster_thermal:schedule_add_node(pos, minetest.get_node(pos))
end

local function solid_fuel_heater_after_destruct(pos, old_node)
  cluster_thermal:schedule_remove_node(pos, old_node)
end

local function solid_fuel_heater_on_rightclick(pos, node, user)
  minetest.show_formspec(
    user:get_player_name(),
    "yatm_foundry:solid_fuel_heater",
    get_solid_fuel_heater_formspec(pos, user)
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
  maybe_start_node_timer(pos, 1.0)
end

local function solid_fuel_heater_node_timer(pos, elapsed)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local fuel_time = meta:get_float("fuel_time") or 0
  local fuel_time_max = meta:get_float("fuel_time_max") or 0
  local heat = meta:get_float("heat") or 0

  if fuel_time > 0 then
    meta:set_float("fuel_time", fuel_time - elapsed)
    meta:set_float("heat", math.min(heat + 10 * elapsed, 3600))

    yatm.queue_refresh_infotext(pos, node)
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

      node.name = "yatm_foundry:solid_fuel_heater_on"
      minetest.swap_node(pos, node)
      yatm.queue_refresh_infotext(pos)
      return true
    else
      meta:set_float("fuel_time", 0)
      meta:set_float("fuel_time_max", 0)

      if heat > 0 then
        -- Heat dissipation logic - wow!
        meta:set_float("heat", math.max(heat - 5 * elapsed, 0))
        yatm.queue_refresh_infotext(pos, node)
        return true
      else
        node.name = "yatm_foundry:solid_fuel_heater_off"
        minetest.swap_node(pos, node)
        yatm.queue_refresh_infotext(pos, node)
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
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    -- TODO: pull the max heat from configuration
    "Heat: " .. heat .. " / 3600" .. "\n" ..
    "Fuel Time: " .. format_pretty_time(fuel_time) .. " / " .. format_pretty_time(fuel_time_max)
  )
end

local solid_fuel_heater_item_interface = ItemInterface.new_simple("fuel_slot")

function solid_fuel_heater_item_interface:on_insert_item(pos, dir, item_stack)
  maybe_start_node_timer(pos, 1.0)
end

function solid_fuel_heater_item_interface:allow_insert_item(pos, dir, item_stack)
  if is_item_solid_fuel(item_stack) then
    return true
  else
    print("Cannot insert", minetest.pos_to_string(pos), inspect_axis(dir), itemstack_inspect(item_stack))
    return false, "item is not solid fuel"
  end
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  heater_device = 1,
  yatm_cluster_thermal = 1,
}

local node_box = {
  type = "fixed",
  fixed = {
    {-0.5, (4 / 16) - 0.5, -0.5, 0.5, 0.5, 0.5},
    {(1 / 16) - 0.5, -0.5, (1 / 16) -0.5, (15 / 16) - 0.5, (4 / 16) - 0.5, (15 / 16) - 0.5},
  }
}

yatm.register_stateful_node("yatm_foundry:solid_fuel_heater", {
  basename = "yatm_foundry:solid_fuel_heater",

  description = "Solid Fuel Heater",

  codex_entry_id = "yatm_foundry:solid_fuel_heater",

  groups = groups,

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("stone"),

  item_interface = solid_fuel_heater_item_interface,

  on_construct = solid_fuel_heater_on_construct,
  after_destruct = solid_fuel_heater_after_destruct,
  on_rightclick = solid_fuel_heater_on_rightclick,
  on_timer = solid_fuel_heater_node_timer,

  allow_metadata_inventory_put = solid_fuel_heater_allow_metadata_inventory_put,
  on_metadata_inventory_put = solid_fuel_heater_on_metadata_inventory_put,

  refresh_infotext = solid_fuel_heater_refresh_infotext,

  thermal_interface = {
    groups = {
      heater = 1,
      thermal_producer = 1,
    },

    get_heat = function (self, pos, node)
      local meta = minetest.get_meta(pos)
      return meta:get_float("heat")
    end,
  },

  use_texture_alpha = "opaque",
}, {
  off = {
    tiles = {
      "yatm_solid_fuel_heater_top.off.png",
      "yatm_solid_fuel_heater_bottom.off.png",
      "yatm_solid_fuel_heater_side.off.png",
      "yatm_solid_fuel_heater_side.off.png^[transformFX",
      "yatm_solid_fuel_heater_side.off.png",
      "yatm_solid_fuel_heater_side.off.png"
    },
  },

  on = {
    groups = table_merge(groups, {not_in_creative_inventory = 1}),

    tiles = {
      "yatm_solid_fuel_heater_top.on.png",
      "yatm_solid_fuel_heater_bottom.on.png",
      "yatm_solid_fuel_heater_side.on.png",
      "yatm_solid_fuel_heater_side.on.png^[transformFX",
      "yatm_solid_fuel_heater_side.on.png",
      "yatm_solid_fuel_heater_side.on.png"
    },
  },
})
