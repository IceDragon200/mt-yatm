--
-- Materializers convert digitized items or fluids back to their physical form
--
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local materializer_yatm_network = {
  kind = "machine",
  groups = {
    dscs_materializer_module = 1,
    energy_consumer = 1,
    item_producer = 1,
    machine_worker = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:materializer_error",
    error = "yatm_dscs:materializer_error",
    off = "yatm_dscs:materializer_off",
    on = "yatm_dscs:materializer_on",
  },
  energy = {
    capacity = 4000,
    startup_threshold = 200,
    network_charge_bandwidth = 100,
    passive_lost = 0, -- materializers won't passively start losing energy
  },
}

function materializer_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local meta = minetest.get_meta(pos)

  return 0
end

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Materializer\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " [" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]\n"

  meta:set_string("infotext", infotext)
end

local groups = {
  cracky = 1,
  yatm_dscs_device = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
  item_interface_out = 1,
  fluid_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:materializer",

  description = "Materializer",

  groups = groups,

  drop = materializer_yatm_network.states.off,

  tiles = {"yatm_materializer_side.off.png"},

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = materializer_yatm_network,
  data_network_device = {
    type = "device",
  },

  refresh_infotext = refresh_infotext,
}, {
  on = {
    tiles = {{
      name = "yatm_materializer_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 4.0
      },
    }},
  },
  error = {
    tiles = {"yatm_materializer_side.error.png"},
  }
})
