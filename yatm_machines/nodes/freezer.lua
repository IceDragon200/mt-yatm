--[[
Freezers solidify liquids, primarily water into ice for transport
]]
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local function freezer_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local freezer_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
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
  return 0
end

local groups = {
  cracky = 1,
  fluid_interface_in = 1,
  item_interface_out = 1
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:freezer",

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

  refresh_infotext = freezer_refresh_infotext,
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
