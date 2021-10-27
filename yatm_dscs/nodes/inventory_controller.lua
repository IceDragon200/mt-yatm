--
-- Inventory Controller
--
-- Inventory controllers are required in a yatm network to store recipes
-- And management automatic crafting, the node in question will remember
-- all active requests.
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local inventory_controller_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
    dscs_inventory_controller = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:inventory_controller_error",
    error = "yatm_dscs:inventory_controller_error",
    off = "yatm_dscs:inventory_controller_off",
    on = "yatm_dscs:inventory_controller_on",
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
    "Inventory Controller\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local groups = {
  cracky = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
  yatm_inventory_controller = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:inventory_controller",

  codex_entry_id = "yatm_dscs:inventory_controller",
  description = "Inventory Controller",

  groups = groups,

  drop = inventory_controller_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_inventory_controller_side.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = inventory_controller_yatm_network,

  refresh_infotext = refresh_infotext,
}, {
  error = {
    tiles = {"yatm_inventory_controller_side.error.png"},
  },
  idle = {
    tiles = {"yatm_inventory_controller_side.idle.png"},
  },
  on = {
    tiles = {
      {
        name = "yatm_inventory_controller_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
  },
})
