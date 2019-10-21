--[[
Freezers solidify liquids, primarily water into ice for transport
]]
local freezer_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:freezer_error",
    error = "yatm_machines:freezer_error",
    off = "yatm_machines:freezer_off",
    on = "yatm_machines:freezer_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 0,
    network_charge_bandwidth = 200,
    startup_threshold = 400,
  },
}

function freezer_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

local groups = {
  cracky = 1,
  fluid_interface_in = 1,
  item_interface_out = 1
}

yatm.devices.register_stateful_network_device({
  description = "Freezer",

  groups = groups,

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
}, {
  error = {
    tiles = {
      "yatm_freezer_top.error.png",
      "yatm_freezer_bottom.error.png",
      "yatm_freezer_side.error.png",
      "yatm_freezer_side.error.png",
      "yatm_freezer_side.error.png",
      "yatm_freezer_side.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_freezer_top.on.png",
      "yatm_freezer_bottom.on.png",
      "yatm_freezer_side.on.png",
      "yatm_freezer_side.on.png",
      "yatm_freezer_side.on.png",
      "yatm_freezer_side.on.png",
    },
  },
})
