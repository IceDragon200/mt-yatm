local Directions = assert(foundation.com.Directions)
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)
local itemstack_copy = assert(foundation.com.itemstack_copy)
local format_pretty_time = assert(foundation.com.format_pretty_time)
local metaref_dec_float = assert(foundation.com.metaref_dec_float)
local cluster_devices = assert(yatm.cluster.devices)
local Energy = assert(yatm.energy)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local ItemInterface = assert(yatm.items.ItemInterface)
local smelting_registry = assert(yatm.smelting.smelting_registry)

local function get_electric_smelter_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine_heated") ..
    "list[nodemeta:" .. spos .. ";input_slot;0,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";processing_slot;2,0.3;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";input_slot]" ..
    "listring[current_player;main]"

  return formspec
end

local electric_smelter_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    heat_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_foundry:electric_smelter_error",
    error = "yatm_foundry:electric_smelter_error",
    off = "yatm_foundry:electric_smelter_off",
    on = "yatm_foundry:electric_smelter_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

local TANK_CAPACITY = 4000
local fluid_interface = FluidInterface.new_simple("molten_tank", TANK_CAPACITY)

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

function fluid_interface:allow_replace(pos, dir, fluid_stack)
  -- If the fluid is molten, then it can be replaced
  if FluidStack.is_member_of_group(fluid_stack, "molten") then
    return true
  else
    return false, "not molten fluid"
  end
end

fluid_interface.allow_fill = fluid_interface.allow_replace
fluid_interface.allow_drain = fluid_interface.allow_replace

local item_interface = ItemInterface.new_simple("input_slot")

function electric_smelter_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)

  local molten_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, "molten_tank")
  local recipe_time = meta:get_float("recipe_time")
  local recipe_time_max = meta:get_float("recipe_time_max")

  local capacity = fluid_interface:get_capacity(pos, 0)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Molten Tank: " .. FluidStack.pretty_format(molten_tank_fluid_stack, capacity) .. "\n" ..
    "Time Remaining: " .. format_pretty_time(recipe_time) .. " / " .. format_pretty_time(recipe_time_max)

  meta:set_string("infotext", infotext)
end

function electric_smelter_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local energy_consumed = 0
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local processing_item_stack = inv:get_stack("processing_slot",  1)
  if itemstack_is_blank(processing_item_stack) then
    local input_item_stack = inv:get_stack("input_slot",  1)

    if not itemstack_is_blank(input_item_stack) then
      local recipe = smelting_registry:get_smelting_recipe(input_item_stack)
      if recipe then
        meta:set_float("recipe_time", recipe.duration)
        meta:set_float("recipe_time_max", recipe.duration)

        local processing_item_stack = itemstack_copy(recipe.source_item_stack)
        inv:add_item("processing_slot", processing_item_stack)
        inv:remove_item("input_slot", processing_item_stack)
      end
    end
  end

  local processing_item_stack = inv:get_stack("processing_slot",  1)
  if not itemstack_is_blank(processing_item_stack) then
    if metaref_dec_float(meta, "recipe_time", dtime) <= 0 then
      local recipe = smelting_registry:get_smelting_recipe(processing_item_stack)
      if recipe then
        local result_fluid_stack = recipe.results[1]
        if FluidMeta.room_for_fluid(meta, "molten_tank", result_fluid_stack, TANK_CAPACITY, TANK_CAPACITY) then
          FluidMeta.fill_fluid(meta, "molten_tank", result_fluid_stack, TANK_CAPACITY, TANK_CAPACITY, true)
          inv:remove_item("processing_slot", processing_item_stack)
          meta:set_float("recipe_time", 0)
          meta:set_float("recipe_time_max", 0)
          yatm.queue_refresh_infotext(pos, node)
        end
      end
    else
      energy_consumed = energy_consumed + 5
    end
  end

  return energy_consumed
end

local groups = {
  cracky = 1,
  fluid_interface_out = 1,
  item_interface_in = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_foundry:electric_smelter",

  description = "Electric Smelter",

  codex_entry_id = "yatm_foundry:electric_smelter",

  groups = groups,

  drop = electric_smelter_yatm_network.states.off,

  tiles = {
    "yatm_electric_smelter_top.off.png",
    "yatm_electric_smelter_bottom.off.png",
    "yatm_electric_smelter_side.off.png",
    "yatm_electric_smelter_side.off.png",
    "yatm_electric_smelter_side.off.png",
    "yatm_electric_smelter_side.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = electric_smelter_yatm_network,
  fluid_interface = fluid_interface,
  item_interface = item_interface,

  refresh_infotext = electric_smelter_refresh_infotext,

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("input_slot", 1)
    inv:set_size("processing_slot", 1)
  end,

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_foundry:electric_smelter",
      get_electric_smelter_formspec(pos, user)
    )
  end,
}, {
  error = {
    tiles = {
      "yatm_electric_smelter_top.error.png",
      "yatm_electric_smelter_bottom.error.png",
      "yatm_electric_smelter_side.error.png",
      "yatm_electric_smelter_side.error.png",
      "yatm_electric_smelter_side.error.png",
      "yatm_electric_smelter_side.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_electric_smelter_top.on.png",
      "yatm_electric_smelter_bottom.on.png",
      "yatm_electric_smelter_side.on.png",
      "yatm_electric_smelter_side.on.png",
      "yatm_electric_smelter_side.on.png",
      "yatm_electric_smelter_side.on.png"
    },
    light_source = 7,
  },
})

