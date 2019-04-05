local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local ItemInterface = assert(yatm.items.ItemInterface)
local MoldingRegistry = assert(yatm.molding.MoldingRegistry)

local function get_electric_molder_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    "list[nodemeta:" .. spos .. ";mold_slot;0,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";output_slot;2,0.3;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";mold_slot]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";output_slot]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

local electric_molder_yatm_network = {
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
    conflict = "yatm_foundry:electric_molder_error",
    error = "yatm_foundry:electric_molder_error",
    off = "yatm_foundry:electric_molder_off",
    on = "yatm_foundry:electric_molder_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

local TANK_CAPACITY = 4000
local fluid_interface = FluidInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP or new_dir == yatm_core.D_DOWN then
    return "molten_tank", TANK_CAPACITY
  end
  return nil
end)

function fluid_interface:allow_replace(pos, dir, fluid_stack)
  local tank_name = self:get_fluid_tank_name(pos, dir)
  if tank_name then
    if tank_name == "molten_tank" then
      local fluid = FluidStack.get_fluid(fluid_stack)
      -- If the fluid is molten, then it can be replaced
      if fluid and fluid.groups.molten then
        return true
      end
    end
  end
  return false
end

fluid_interface.allow_fill = fluid_interface.allow_replace
fluid_interface.allow_drain = fluid_interface.allow_replace

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP or new_dir == yatm_core.D_DOWN then
    return "mold_slot"
  end
  return "output_slot"
end)

function electric_molder_yatm_network.work(pos, node, available_energy, work_rate, ot)
  local energy_consumed = 0
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local molding_fluid = FluidMeta.get_fluid_stack(meta, "molding_tank")
  if not FluidStack.presence(molding_fluid) then
    local mold_item_stack = inv:get_stack("mold_slot",  1)

    if not yatm_core.itemstack_is_blank(mold_item_stack) then
      local molten_fluid = FluidMeta.get_fluid_stack(meta, "molten_tank")
      local recipe = MoldingRegistry:get_molding_recipe(mold_item_stack, molten_fluid)
      if recipe then
        meta:set_int("duration", recipe.duration)
        local drained_fluid = FluidMeta.drain_fluid(meta, "molten_tank", recipe.molten_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
        FluidMeta.fill_fluid(meta, "molding_tank", drained_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
      end
    end
  end

  local molding_fluid = FluidMeta.get_fluid_stack(meta, "molding_tank")
  if FluidStack.presence(molding_fluid) then
    if yatm_core.metaref_dec_int(meta, "duration", 1) <= 0 then
      local mold_item_stack = inv:get_stack("mold_slot",  1)
      local recipe = MoldingRegistry:get_molding_recipe(mold_item_stack, molding_fluid)

      if inv:room_for_item("output_slot", recipe.result_item_stack) then
        local result = yatm_core.itemstack_copy(recipe.result_item_stack)

        inv:add_item("output_slot", result)
        FluidMeta.drain_fluid(meta, "molten_tank", recipe.molten_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
      end
    else
      energy_consumed = energy_consumed + 5
    end
  end

  return energy_consumed
end

local groups = {
  cracky = 1,
  fluid_interface_in = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Electric Molder",

  groups = groups,

  drop = electric_molder_yatm_network.states.off,

  tiles = {
    "yatm_electric_molder_top.off.png",
    "yatm_electric_molder_bottom.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png"
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, (12 / 16.0) - 0.5, 0.5}, -- Base
      {-0.5, (15 / 16.0) - 0.5, -0.5, 0.5, 0.5, 0.5}, -- Cap
      -- Columns
      {(1 / 16.0) - 0.5, (12 / 16.0) - 0.5, (1 / 16.0) - 0.5, (3 / 16.0) - 0.5, (15 / 16.0) - 0.5, (3 / 16.0) - 0.5},
      {(1 / 16.0) - 0.5, (12 / 16.0) - 0.5, (13 / 16.0) - 0.5, (3 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5},
      {(13 / 16.0) - 0.5, (12 / 16.0) - 0.5, (1 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5, (3 / 16.0) - 0.5},
      {(13 / 16.0) - 0.5, (12 / 16.0) - 0.5, (13 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5},
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = electric_molder_yatm_network,
  fluid_interface = fluid_interface,
  item_interface = item_interface,

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("mold_slot", 1)
    inv:set_size("output_slot", 1)
  end,

  on_rightclick = function (pos, node, clicker)
    minetest.show_formspec(
      clicker:get_player_name(),
      "yatm_foundry:electric_molder",
      get_electric_molder_formspec(pos)
    )
  end,
}, {
  error = {
    tiles = {
      "yatm_electric_molder_top.error.png",
      "yatm_electric_molder_bottom.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_electric_molder_top.on.png",
      "yatm_electric_molder_bottom.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png"
    },
  },
})

