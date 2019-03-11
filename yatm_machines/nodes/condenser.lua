--[[
Condensers turn gases into liquids, primarily steam back into water.
]]
local condenser_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:condenser_error",
    error = "yatm_machines:condenser_error",
    off = "yatm_machines:condenser_off",
    on = "yatm_machines:condenser_on",
  }
}

local capacity = 16000
local function get_fluid_tank_name(_self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_DOWN then
    return "water_tank", capacity
  elseif new_dir == yatm_core.D_UP or
         new_dir == yatm_core.D_EAST or
         new_dir == yatm_core.D_WEST or
         new_dir == yatm_core.D_NORTH or
         new_dir == yatm_core.D_SOUTH then
    return "steam_tank", capacity
  end
  return nil, nil
end

local fluids_interface = yatm_core.new_directional_fluids_interface(get_fluid_tank_name)

function condenser_yatm_network.update(pos, node, ot)
  --
end

yatm_machines.register_network_device(condenser_yatm_network.states.off, {
  description = "Condenser",
  groups = {cracky = 1},
  drop = condenser_yatm_network.states.off,
  tiles = {
    "yatm_condenser_top.off.png",
    "yatm_condenser_bottom.off.png",
    "yatm_condenser_side.off.png",
    "yatm_condenser_side.off.png^[transformFX",
    "yatm_condenser_back.off.png",
    "yatm_condenser_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = condenser_yatm_network,
  fluids_interface = fluids_interface,
})

yatm_machines.register_network_device(condenser_yatm_network.states.error, {
  description = "Condenser",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = condenser_yatm_network.states.off,
  tiles = {
    "yatm_condenser_top.error.png",
    "yatm_condenser_bottom.error.png",
    "yatm_condenser_side.error.png",
    "yatm_condenser_side.error.png^[transformFX",
    "yatm_condenser_back.error.png",
    "yatm_condenser_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = condenser_yatm_network,
  fluids_interface = fluids_interface,
})

yatm_machines.register_network_device(condenser_yatm_network.states.on, {
  description = "Condenser",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = condenser_yatm_network.states.off,
  tiles = {
    {
      name = "yatm_condenser_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.4
      },
    },
    "yatm_condenser_bottom.on.png",
    "yatm_condenser_side.on.png",
    "yatm_condenser_side.on.png^[transformFX",
    {
      name = "yatm_condenser_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.4
      },
    },
    "yatm_condenser_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = condenser_yatm_network,
  fluids_interface = fluids_interface,
})
