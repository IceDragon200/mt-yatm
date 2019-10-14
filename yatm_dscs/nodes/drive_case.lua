local function get_drive_case_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    "list[nodemeta:" .. spos .. ";drive_bay;0,0.3;2,4;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";drive_bay]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

local drive_case_yatm_network = {
  kind = "machine",

  groups = {
    drive_case = 1,
    energy_consumer = 1,
    dscs_storage_module = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_dscs:drive_case_error",
    error = "yatm_dscs:drive_case_error",
    off = "yatm_dscs:drive_case_off",
    on = "yatm_dscs:drive_case_on",
  },

  energy = {
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  description = "Drive Case",

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
    yatm_network_device = 1,
  },

  drop = drive_case_yatm_network.states.off,

  tiles = {
    "yatm_drive_case_top.off.png",
    "yatm_drive_case_bottom.png",
    "yatm_drive_case_side.off.png",
    "yatm_drive_case_side.off.png^[transformFX",
    "yatm_drive_case_back.off.png",
    "yatm_drive_case_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = drive_case_yatm_network,

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("drive_bay", 8)
  end,

  on_rightclick = function (pos, node, clicker)
    minetest.show_formspec(
      clicker:get_player_name(),
      "yatm_dscs:drive_case",
      get_drive_case_formspec(pos)
    )
  end,
}, {
  on = {
    tiles = {
      "yatm_drive_case_top.on.png",
      "yatm_drive_case_bottom.png",
      "yatm_drive_case_side.on.png",
      "yatm_drive_case_side.on.png^[transformFX",
      "yatm_drive_case_back.on.png",
      "yatm_drive_case_front.on.png"
    },
  },
  error = {
    tiles = {
      "yatm_drive_case_top.error.png",
      "yatm_drive_case_bottom.png",
      "yatm_drive_case_side.error.png",
      "yatm_drive_case_side.error.png^[transformFX",
      "yatm_drive_case_back.error.png",
      "yatm_drive_case_front.error.png"
    },
  }
})
