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

local fluids_interface = {}
local capacity = 16000
local function get_fluid_tank_name(pos, dir, node)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_DOWN then
    return "water_tank"
  elseif new_dir == yatm_core.D_EAST or
         new_dir == yatm_core.D_WEST or
         new_dir == yatm_core.D_NORTH or
         new_dir == yatm_core.D_SOUTH then
    return "steam_tank"
  end
  return nil
end

function fluids_interface.get(pos, dir, node)
  local meta = minetest.get_meta(pos)
  local tank_name = get_fluid_tank_name(pos, dir, node)
  if tank_name then
    local stack = yatm_core.fluids.get_fluid(meta, tank_name)
    return stack
  end
  return nil
end

function fluids_interface.replace(pos, dir, node, fluid_name, amount, commit)
  local meta = minetest.get_meta(pos)
  local tank_name = get_fluid_tank_name(pos, dir, node)
  if tank_name then
    local stack, new_amount = yatm_core.fluids.set_fluid(meta, tank_name, fluid_name, amount, commit)
    return stack
  end
  return nil
end

function fluids_interface.fill(pos, dir, node, fluid_name, amount, commit)
  local meta = minetest.get_meta(pos)
  local tank_name = get_fluid_tank_name(pos, dir, node)
  if tank_name then
    local stack, new_amount = yatm_core.fluids.fill_fluid(meta, tank_name, fluid_name, amount, capacity, capacity, commit)
    return stack
  end
  return nil
end

function fluids_interface.drain(pos, dir, node, fluid_name, amount, commit)
  local meta = minetest.get_meta(pos)
  local tank_name = get_fluid_tank_name(pos, dir, node)
  if tank_name then
    local stack, new_amount = yatm_core.fluids.drain_fluid(meta, tank_name, fluid_name, amount, capacity, capacity, commit)
    return stack
  end
  return nil
end

function steam_turbine_yatm_network.produce_energy(pos, node, ot)
  local stack, new_amount = yatm_core.fluids.drain_fluid(meta, "steam_tank", "yatm_reactors:steam", 1000, capacity, capacity, false)
  if stack then
    local filled_stack, new_amount = yatm_core.fluids.fill_fluid(meta, "water_tank", "default:water", stack.amount, capacity, capacity, true)
    if filled_stack then
      local stack, new_amount = yatm_core.fluids.drain_fluid(meta, "steam_tank", "yatm_reactors:steam", filled_stack.amount, capacity, capacity, true)
      return filled_stack.amount
    end
  end
  return 0
end

function steam_turbine_yatm_network.update(pos, node, ot)
  for _, dir in yatm_core.DIR4 do
    local new_dir = yatm_core.facedir_to_face(node.param2, dir)

    local npos = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_dir])
    local nnode = minetest.get_node(npos)
    local nnodedef = minetest.registered_nodes[nnode.name]
    if nnodedef then
      if yatm_core.groups.get_item(nnodedef, "fluid_tank") then
        local target_dir = yatm_core.invert_dir(new_dir)
        local stack = yatm_core.fluid_tanks.drain(npos, target_dir, "yatm_reactors:steam", 1000, false)
        if stack then
          local filled_stack = yatm_core.fluid_tanks.fill(pos, new_dir, stack.name, stack.amount, true)
          if filled_stack then
            yatm_core.fluid_tanks.drain(npos, target_dir, filled_stack.name, filled_stack.amount, true)
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
