local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)

local solar_panel_yatm_network = {
  kind = "energy_producer",
  groups = {
    device_controller = 3,
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
  -- TODO: can we get sunlight instead?
  local meta = minetest.get_meta(pos)
  local light = minetest.get_node_light(pos, nil)
  local energy = 0
  if light > 5 then
    energy = light * 3
  end
  yatm.queue_refresh_infotext(pos, node)
  meta:set_int("last_produced_energy", energy)
  return energy
end

function solar_panel_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local last_produced_energy = meta:get_int("last_produced_energy")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "[+ " .. last_produced_energy .. "]"

  meta:set_string("infotext", infotext)
end

local solar_panel_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (4 / 16) - 0.5, 0.5},
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_solar_energy:solar_panel",

  description = "Solar Panel",

  codex_entry_id = "yatm_solar_energy:solar_panel",

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
  },

  drop = solar_panel_yatm_network.states.off,

  sounds = yatm.node_sounds:build("glass"),

  tiles = {
    "yatm_solar_panel_top.off.png",
    "yatm_solar_panel_bottom.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
  },
  use_texture_alpha = "opaque",

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
    use_texture_alpha = "opaque",
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
    use_texture_alpha = "opaque",
  }
})
