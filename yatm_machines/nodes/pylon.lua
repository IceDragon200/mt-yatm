local mod = yatm_machines
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local function pylon_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local pylon_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:pylon_error",
    error = "yatm_machines:pylon_error",
    off = "yatm_machines:pylon_off",
    on = "yatm_machines:pylon_on",
  },
  energy = {
    capacity = 6000,
    network_charge_bandwidth = 200,
    passive_lost = 10,
    startup_threshold = 1000,
  }
}

function pylon_yatm_network:work(ctx)
  return 0
end

local pylon_side_animation = {
  name = "yatm_pylon_side.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1
  },
}

local pylon_node_box = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375},
    {-0.4375, -0.5, -0.1875, 0.4375, -0.125, 0.1875},
    {-0.1875, -0.5, -0.4375, 0.1875, -0.125, 0.4375},
  }
}

yatm.devices.register_stateful_network_device({
  basename = mod:make_name("pylon"),

  description = mod.S("Pylon"),

  groups = {
    cracky = nokore.dig_class("copper"),
  },

  drop = mod:make_name("pylon_off"),

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_pylon_top.off.png",
    "yatm_pylon_bottom.off.png",
    "yatm_pylon_side.off.png",
    "yatm_pylon_side.off.png",
    "yatm_pylon_side.off.png",
    "yatm_pylon_side.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",

  node_box = pylon_node_box,

  yatm_network = pylon_yatm_network,

  refresh_infotext = pylon_refresh_infotext,
}, {
  error = {
    tiles = {
      {
        name = "yatm_pylon_top.error.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
      {
        name = "yatm_pylon_bottom.error.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
      "yatm_pylon_side.error.png",
      "yatm_pylon_side.error.png",
      "yatm_pylon_side.error.png",
      "yatm_pylon_side.error.png",
    },
  },

  on = {
    tiles = {
      {
        name = "yatm_pylon_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
      {
        name = "yatm_pylon_bottom.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
      pylon_side_animation,
      pylon_side_animation,
      pylon_side_animation,
      pylon_side_animation,
    },
  }
})
