--[[
Freezers solidify liquids, primarily water into ice for transport
]]
local freezer_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:freezer_error",
    error = "yatm_machines:freezer_error",
    off = "yatm_machines:freezer_off",
    on = "yatm_machines:freezer_on",
  },
  passive_energy_lost = 0
}

function freezer_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm.devices.register_network_device(freezer_yatm_network.states.off, {
  description = "Freezer",
  groups = {cracky = 1},
  drop = freezer_yatm_network.states.off,
  tiles = {
    "yatm_freezer_top.off.png",
    "yatm_freezer_bottom.off.png",
    "yatm_freezer_side.off.png",
    "yatm_freezer_side.off.png",
    "yatm_freezer_side.off.png",
    "yatm_freezer_side.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = freezer_yatm_network,
})

yatm.devices.register_network_device(freezer_yatm_network.states.error, {
  description = "Freezer",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = freezer_yatm_network.states.off,
  tiles = {
    "yatm_freezer_top.error.png",
    "yatm_freezer_bottom.error.png",
    "yatm_freezer_side.error.png",
    "yatm_freezer_side.error.png",
    "yatm_freezer_side.error.png",
    "yatm_freezer_side.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = freezer_yatm_network,
})

yatm.devices.register_network_device(freezer_yatm_network.states.on, {
  description = "Freezer",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = freezer_yatm_network.states.off,
  tiles = {
    "yatm_freezer_top.on.png",
    "yatm_freezer_bottom.on.png",
    "yatm_freezer_side.on.png",
    "yatm_freezer_side.on.png",
    "yatm_freezer_side.on.png",
    "yatm_freezer_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = freezer_yatm_network,
})
