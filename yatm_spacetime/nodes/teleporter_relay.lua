--[[

  Teleporter relays are neutral nodes that are placed adjacent to a teleporter to expand it's teleportation effect range

]]
local mod = assert(yatm_spacetime)

local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local function teleporter_relay_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local teleporter_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (1 / 16) - 0.5, 0.5},
  }
}

local teleporter_relay_yatm_network = {
  kind = "machine",
  groups = {
    teleporter_relay = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_spacetime:teleporter_relay_error",
    error = "yatm_spacetime:teleporter_relay_error",
    off = "yatm_spacetime:teleporter_relay_off",
    on = "yatm_spacetime:teleporter_relay_on",
    inactive = "yatm_spacetime:teleporter_relay_inactive",
  },
  energy = {
    capacity = 4000,
    passive_lost = 5,
    network_charge_bandwidth = 100,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_spacetime:teleporter_relay",

  description = mod.S("Teleporter Relay"),

  codex_entry_id = "yatm_spacetime:teleporter_relay",

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    spacetime_device = 1,
    teleporter_relay = 1,
    yatm_energy_device = 1,
    yatm_cluster_device = 1,
    yatm_cluster_energy = 1,
  },

  drop = teleporter_relay_yatm_network.states.off,

  tiles = {
    "yatm_teleporter_relay_top.off.png",
    "yatm_teleporter_relay_bottom.png",
    "yatm_teleporter_relay_side.off.png",
    "yatm_teleporter_relay_side.off.png^[transformFX",
    "yatm_teleporter_relay_side.off.png",
    "yatm_teleporter_relay_side.off.png",
  },
  use_texture_alpha = "opaque",
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,

  yatm_network = teleporter_relay_yatm_network,

  refresh_infotext = teleporter_relay_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_teleporter_relay_top.error.png",
      "yatm_teleporter_relay_bottom.png",
      "yatm_teleporter_relay_side.error.png",
      "yatm_teleporter_relay_side.error.png^[transformFX",
      "yatm_teleporter_relay_side.error.png",
      "yatm_teleporter_relay_side.error.png",
    },
  },
  inactive = {
    tiles = {
      "yatm_teleporter_relay_top.inactive.png",
      "yatm_teleporter_relay_bottom.png",
      "yatm_teleporter_relay_side.inactive.png",
      "yatm_teleporter_relay_side.inactive.png^[transformFX",
      "yatm_teleporter_relay_side.inactive.png",
      "yatm_teleporter_relay_side.inactive.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_teleporter_relay_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_teleporter_relay_bottom.png",
      "yatm_teleporter_relay_side.on.png",
      "yatm_teleporter_relay_side.on.png^[transformFX",
      "yatm_teleporter_relay_side.on.png^[transformFX",
      "yatm_teleporter_relay_side.on.png",
    },
  },
})
