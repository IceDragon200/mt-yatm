--
-- Void crates can view the contents of a fluid drive, and only a fluid drive.
--
local void_crate_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:void_crate_error",
    error = "yatm_dscs:void_crate_error",
    off = "yatm_dscs:void_crate_off",
    on = "yatm_dscs:void_crate_on",
  },
  energy = {
    passive_lost = 1,
  },
}

local groups = {
  cracky = 1,
  fluid_interface_out = 1,
  fluid_interface_in = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:void_crate",

  description = "Void Crate\nInstall a fluid drive to access it's contents.",

  groups = groups,

  drop = void_crate_yatm_network.states.off,

  tiles = {
    "yatm_void_crate_top.off.png",
    "yatm_void_crate_bottom.png",
    "yatm_void_crate_side.off.png",
    "yatm_void_crate_side.off.png^[transformFX",
    "yatm_void_crate_back.off.png",
    "yatm_void_crate_front.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = function (pos)
    local node = minetest.get_node(pos)

    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()
    inv:set_size("drive_slot", 1)
  end,

  yatm_network = void_crate_yatm_network,
  on_rightclick = function (pos, node, clicker)
  end,
}, {
  error = {
    tiles = {
      "yatm_void_crate_top.error.png",
      "yatm_void_crate_bottom.png",
      "yatm_void_crate_side.error.png",
      "yatm_void_crate_side.error.png^[transformFX",
      "yatm_void_crate_back.error.png",
      "yatm_void_crate_front.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_void_crate_top.on.png",
      "yatm_void_crate_bottom.png",
      {
        name = "yatm_void_crate_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      {
        name = "yatm_void_crate_side.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      "yatm_void_crate_back.on.png",
      "yatm_void_crate_front.on.png",
    },
  }
})
