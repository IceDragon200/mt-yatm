local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)

--[[
Steam turbines produce energy by consuming steam, they have the byproduct of water which can be cycled again into a boiler.
]]
local steam_turbine_yatm_network = {
  kind = "energy_producer",
  groups = {
    energy_producer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:steam_turbine_error",
    error = "yatm_machines:steam_turbine_error",
    off = "yatm_machines:steam_turbine_off",
    on = "yatm_machines:steam_turbine_on",
  }
}

local capacity = 16000
local WATER_TANK = "water_tank"
local STEAM_TANK = "steam_tank"
local function get_fluid_tank_name(_self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_DOWN then
    return WATER_TANK, capacity
  elseif new_dir == yatm_core.D_EAST or
         new_dir == yatm_core.D_WEST or
         new_dir == yatm_core.D_NORTH or
         new_dir == yatm_core.D_SOUTH then
    return STEAM_TANK, capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)

function steam_turbine_yatm_network.produce_energy(pos, node, ot)
  local meta = minetest.get_meta(pos)
  local stack, new_amount = FluidMeta.drain_fluid(meta,
    STEAM_TANK,
    FluidStack.new("group:steam", 100),
    capacity, capacity, false)
  if stack then
    local filled_stack, new_amount = FluidMeta.fill_fluid(meta,
      WATER_TANK,
      FluidStack.set_name(stack, "default:water"),
      capacity, capacity, true)
    if filled_stack then
      local stack, new_amount = FluidMeta.drain_fluid(meta,
        STEAM_TANK,
        FluidStack.set_amount(stack, filled_stack.amount),
        capacity, capacity, true)
      return filled_stack.amount
    end
  end
  return 0
end

function steam_turbine_yatm_network.update(pos, node, ot)
  for _, dir in ipairs(yatm_core.DIR4) do
    local new_dir = yatm_core.facedir_to_face(node.param2, dir)

    local npos = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_dir])
    local nnode = minetest.get_node(npos)
    local nnodedef = minetest.registered_nodes[nnode.name]
    if nnodedef then
      if yatm_core.groups.get_item(nnodedef, "fluid_tank") then
        local target_dir = yatm_core.invert_dir(new_dir)
        local stack = FluidTanks.drain(npos, target_dir, FluidStack.new("group:steam", 200), false)
        if stack then
          local filled_stack = FluidTanks.fill(pos, new_dir, stack, true)
          if filled_stack then
            FluidTanks.drain(npos, target_dir, filled_stack, true)
          end
        end
      end
    end
  end

  local meta = minetest.get_meta(pos)

  do -- Deposit water to a bottom tank
    local stack, new_amount = FluidMeta.drain_fluid(meta,
      WATER_TANK,
      FluidStack.new("group:water", 1000),
      capacity, capacity, false)
    -- Was any water drained?
    if stack then
      local tank_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
      local tank_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[tank_dir])
      local tank_node = minetest.get_node(tank_pos)
      local tank_nodedef = minetest.registered_nodes[tank_node.name]
      if tank_nodedef then
        if yatm_core.groups.get_item(tank_nodedef, "fluid_tank") then
          local drained_stack, new_amount = FluidTanks.fill(tank_pos, yatm_core.invert_dir(tank_dir), stack, true)
          if drained_stack then
            FluidMeta.drain_fluid(meta,
              WATER_TANK,
              FluidStack.set_amount(stack, drained_stack.amount),
              capacity, capacity, true)
          end
        end
      end
    end
  end
end

local groups = {cracky = 1, yatm_network_host = 2, fluid_interface_in = 1, fluid_interface_out = 1}
local table_merge = assert(yatm_core.table_merge)

yatm.devices.register_network_device(steam_turbine_yatm_network.states.off, {
  description = "Steam Turbine",
  groups = groups,
  drop = steam_turbine_yatm_network.states.off,
  tiles = {
    "yatm_steam_turbine_top.off.png",
    "yatm_steam_turbine_bottom.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = steam_turbine_yatm_network,
  fluid_interface = fluid_interface,
})

yatm.devices.register_network_device(steam_turbine_yatm_network.states.error, {
  description = "Steam Turbine",
  groups = table_merge(groups, {not_in_creative_inventory = 1}),
  drop = steam_turbine_yatm_network.states.off,
  tiles = {
    "yatm_steam_turbine_top.error.png",
    "yatm_steam_turbine_bottom.png",
    "yatm_steam_turbine_side.error.png",
    "yatm_steam_turbine_side.error.png",
    "yatm_steam_turbine_side.error.png",
    "yatm_steam_turbine_side.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = steam_turbine_yatm_network,
  fluid_interface = fluid_interface,
})

yatm.devices.register_network_device(steam_turbine_yatm_network.states.on, {
  description = "Steam Turbine",
  groups = table_merge(groups, {not_in_creative_inventory = 1}),
  drop = steam_turbine_yatm_network.states.off,
  tiles = {
    {
      name = "yatm_steam_turbine_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.4
      },
    },
    "yatm_steam_turbine_bottom.png",
    "yatm_steam_turbine_side.on.png",
    "yatm_steam_turbine_side.on.png",
    "yatm_steam_turbine_side.on.png",
    "yatm_steam_turbine_side.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = steam_turbine_yatm_network,
  fluid_interface = fluid_interface,
})
