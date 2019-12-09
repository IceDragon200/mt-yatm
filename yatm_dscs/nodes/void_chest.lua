local function get_void_chests_formspec(pos, user, pointed_thing, assigns)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.bg.machine ..
    "label[0,0;Void Chest]"

  return formspec
end

local void_chest_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:void_chest_error",
    error = "yatm_dscs:void_chest_error",
    off = "yatm_dscs:void_chest_off",
    on = "yatm_dscs:void_chest_on",
  },
  energy = {
    passive_lost = 1,
  },
}

local groups = {
  cracky = 1,
  item_interface_out = 1,
  item_interface_in = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
}

local function receive_fields(pos)
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:void_chest",

  description = "Void Chest",

  groups = groups,

  drop = void_chest_yatm_network.states.off,

  tiles = {
    "yatm_void_chest_top.off.png",
    "yatm_void_chest_bottom.png",
    "yatm_void_chest_side.off.png",
    "yatm_void_chest_side.off.png^[transformFX",
    "yatm_void_chest_back.off.png",
    "yatm_void_chest_front.off.png",
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

  yatm_network = void_chest_yatm_network,
  on_rightclick = function (pos, node, user)
    local assigns = { pos = pos, node = node }
    local formspec = get_void_chest_formspec(pos, user, pointed_thing, assigns)
    local formspec_name = "yatm_dscs:void_chest:" .. minetest.pos_to_string(pos)

    yatm_core.bind_on_player_receive_fields(user, formspec_name,
                                            assigns,
                                            receive_fields)

    minetest.show_formspec(
      user:get_player_name(),
      formspec_name,
      formspec
    )
  end,
}, {
  error = {
    tiles = {
      "yatm_void_chest_top.error.png",
      "yatm_void_chest_bottom.png",
      "yatm_void_chest_side.error.png",
      "yatm_void_chest_side.error.png^[transformFX",
      "yatm_void_chest_back.error.png",
      "yatm_void_chest_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_void_chest_top.on.png",
      "yatm_void_chest_bottom.png",
      {
        name = "yatm_void_chest_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      {
        name = "yatm_void_chest_side.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      "yatm_void_chest_back.on.png",
      "yatm_void_chest_front.on.png",
    },
  }
})
