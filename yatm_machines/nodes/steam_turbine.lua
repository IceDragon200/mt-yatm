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
local function get_fluid_tank_name(pos, dir, node)
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

local fluids_interface = yatm_core.new_directional_fluids_interface(get_fluid_tank_name)

function steam_turbine_yatm_network.produce_energy(pos, node, ot)
  local meta = minetest.get_meta(pos)
  local stack, new_amount = yatm_core.fluids.drain_fluid(meta, STEAM_TANK, "group:steam", 100, capacity, capacity, false)
  if stack then
    local filled_stack, new_amount = yatm_core.fluids.fill_fluid(meta, WATER_TANK, "default:water", stack.amount, capacity, capacity, true)
    if filled_stack then
      local stack, new_amount = yatm_core.fluids.drain_fluid(meta, STEAM_TANK, stack.name, filled_stack.amount, capacity, capacity, true)
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
        local stack = yatm_core.fluid_tanks.drain(npos, target_dir, "group:steam", 200, false)
        if stack then
          local filled_stack = yatm_core.fluid_tanks.fill(pos, new_dir, stack.name, stack.amount, true)
          if filled_stack then
            yatm_core.fluid_tanks.drain(npos, target_dir, filled_stack.name, filled_stack.amount, true)
          end
        end
      end
    end
  end

  local meta = minetest.get_meta(pos)

  do -- Deposit water to a bottom tank
    local stack, new_amount = yatm_core.fluids.drain_fluid(meta, "water_tank", "group:water", 1000, capacity, capacity, false)
    -- Was any water drained?
    if stack then
      local tank_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
      local tank_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[tank_dir])
      local tank_node = minetest.get_node(tank_pos)
      local tank_nodedef = minetest.registered_nodes[tank_node.name]
      if tank_nodedef then
        if yatm_core.groups.get_item(tank_nodedef, "fluid_tank") then
          local drained_stack, new_amount = yatm_core.fluid_tanks.fill(tank_pos, yatm_core.invert_dir(tank_dir), stack.name, stack.amount, true)
          if drained_stack then
            yatm_core.fluids.drain_fluid(meta, "water_tank", stack.name, drained_stack.amount, capacity, capacity, true)
          end
        end
      end
    end
  end
end

yatm_machines.register_network_device(steam_turbine_yatm_network.states.off, {
  description = "Steam Turbine",
  groups = {cracky = 1, yatm_network_host = 2},
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
  fluids_interface = fluids_interface,
})

yatm_machines.register_network_device(steam_turbine_yatm_network.states.error, {
  description = "Steam Turbine",
  groups = {cracky = 1, yatm_network_host = 2, not_in_creative_inventory = 1},
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
  fluids_interface = fluids_interface,
})

yatm_machines.register_network_device(steam_turbine_yatm_network.states.on, {
  description = "Steam Turbine",
  groups = {cracky = 1, yatm_network_host = 2, not_in_creative_inventory = 1},
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
  fluids_interface = fluids_interface,
})
