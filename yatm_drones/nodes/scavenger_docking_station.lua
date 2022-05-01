local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local docking_station_yatm_network = {
  kind = "machine",

  groups = {
    energy_consumer = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_drones:scavenger_docking_station_error",
    error = "yatm_drones:scavenger_docking_station_error",
    off = "yatm_drones:scavenger_docking_station_off",
    on = "yatm_drones:scavenger_docking_station_on",
  },

  energy = {
    capacity = 16000,
    network_charge_bandwidth = 500,
    passive_lost = 10,
    startup_threshold = 1000,
  },
}

function docking_station_yatm_network.charge_drone(pos, node, drone)
  local meta = minetest.get_meta(pos)
  -- TODO: charge drone

  local amount = Energy.consume_meta_energy(meta, yatm.devices.ENERGY_BUFFER_KEY, 500, 500, 16000, false)
  local amount_used = drone.energy.receive_energy(drone, amount)

  if amount_used <= amount then
    Energy.consume_meta_energy(meta, yatm.devices.ENERGY_BUFFER_KEY, amount_used, 500, 16000, true)
  end
end

local function docking_station_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "[" .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]"

  meta:set_string("infotext", infotext)
end

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_drones:scavenger_docking_station",

  basename = "yatm_drones:scavenger_docking_station",

  description = "Scavenger Docking Station",

  drop = docking_station_yatm_network.states.off,

  groups = {
    cracky = 1,
    -- So scavengers know what to look for when docking
    scavenger_docking_station = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 1, 16),
      ng(0, 1,14, 16, 7,  2),
    },
  },
  tiles = {
    "yatm_scavenger_docking_station_top.charging.off.png",
    "yatm_scavenger_docking_station_bottom.off.png",
    "yatm_scavenger_docking_station_side.png",
    "yatm_scavenger_docking_station_side.png^[transformFX",
    "yatm_scavenger_docking_station_back.png",
    "yatm_scavenger_docking_station_front.off.png",
  },
  use_texture_alpha = "opaque",

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = docking_station_yatm_network,
  refresh_infotext = docking_station_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_scavenger_docking_station_top.charging.error.png",
      "yatm_scavenger_docking_station_bottom.error.png",
      "yatm_scavenger_docking_station_side.png",
      "yatm_scavenger_docking_station_side.png^[transformFX",
      "yatm_scavenger_docking_station_back.png",
      "yatm_scavenger_docking_station_front.error.png",
    },
    use_texture_alpha = "opaque",
  },

  on = {
    tiles = {
      "yatm_scavenger_docking_station_top.charging.on.png",
      "yatm_scavenger_docking_station_bottom.on.png",
      "yatm_scavenger_docking_station_side.png",
      "yatm_scavenger_docking_station_side.png^[transformFX",
      "yatm_scavenger_docking_station_back.png",
      "yatm_scavenger_docking_station_front.on.png",
    },
    use_texture_alpha = "opaque",
  },
})
