local Network = assert(yatm.network)

local solar_panel_yatm_network = {
  kind = "energy_producer",
  groups = {
    energy_producer = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_solar_energy:solar_panel_error",
    error = "yatm_solar_energy:solar_panel_error",
    off = "yatm_solar_energy:solar_panel_off",
    on = "yatm_solar_energy:solar_panel_on",
  },

  energy = {
    capacity = 16000,
  }
}

function solar_panel_yatm_network.energy.produce_energy(pos, node, dtime, ot)
  local light = minetest.get_node_light(pos, nil)
  return light * 3
end

function solar_panel_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    "Network ID: " .. Network.to_infotext(meta)

  meta:set_string("infotext", infotext)
end

local solar_panel_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (4 / 16) - 0.5, 0.5},
  },
}

yatm.devices.register_stateful_network_device({
  description = "Solar Panel",


  groups = {
    cracky = 1,
    yatm_network_host = 3,
    yatm_energy_device = 1,
  },

  drop = solar_panel_yatm_network.states.off,

  sounds = default.node_sound_glass_defaults(),

  tiles = {
    "yatm_solar_panel_top.off.png",
    "yatm_solar_panel_bottom.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
  },
  drawtype = "nodebox",
  node_box = solar_panel_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = solar_panel_yatm_network,

  refresh_infotext = solar_panel_refresh_infotext,
}, {
  on = {
    tiles = {
      "yatm_solar_panel_top.on.png",
      "yatm_solar_panel_bottom.on.png",
      "yatm_solar_panel_side.on.png",
      "yatm_solar_panel_side.on.png",
      "yatm_solar_panel_side.on.png",
      "yatm_solar_panel_side.on.png",
    },
  },
  error = {
    tiles = {
      "yatm_solar_panel_top.error.png",
      "yatm_solar_panel_bottom.error.png",
      "yatm_solar_panel_side.error.png",
      "yatm_solar_panel_side.error.png",
      "yatm_solar_panel_side.error.png",
      "yatm_solar_panel_side.error.png",
    },
  }
})
