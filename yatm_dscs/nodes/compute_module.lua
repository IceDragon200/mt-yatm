--[[

  Compute Modules are no-op blocks that act as a bonus modifier to assemblers on the network.

  Each compute module will speed up the auto-crafting by parallel processing other requests.

]]
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local compute_module_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
    dscs_compute_module = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:compute_module_error",
    error = "yatm_dscs:compute_module_error",
    off = "yatm_dscs:compute_module_off",
    on = "yatm_dscs:compute_module_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 10,
    network_charge_bandwidth = 100,
  },
}

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Compute Module\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " [" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]\n"

  meta:set_string("infotext", infotext)
end

local groups = {
  cracky = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:compute_module",

  codex_entry_id = "yatm_dscs:compute_module",

  description = "Assembler Compute Module",

  groups = groups,

  drop = compute_module_yatm_network.states.off,

  tiles = {"yatm_compute_module_side.off.png"},

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = compute_module_yatm_network,

  refresh_infotext = refresh_infotext,
}, {
  on = {
    tiles = {{
      name = "yatm_compute_module_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    }},
  },
  error = {
    tiles = {"yatm_compute_module_side.error.png"},
  }
})
