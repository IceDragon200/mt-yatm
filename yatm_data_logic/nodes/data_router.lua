local Vector3 = assert(foundation.com.Vector3)
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local data_network = assert(yatm.data_network)
local ByteEncoder = assert(yatm.ByteEncoder)

minetest.register_node("yatm_data_logic:data_router", {
  description = "DATA Router\nInspects input payloads and routes them based on leading bytes.",

  codex_entry_id = "yatm_data_logic:data_router",

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16,  4, 16), -- base
      ng(4, 4, 4, 8, 7, 8), -- core
      ng(3, 4, 3, 4, 8, 4), -- pillar
      ng(3, 4, 9, 4, 8, 4), -- pillar
      ng(9, 4, 3, 4, 8, 4), -- pillar
      ng(9, 4, 9, 4, 8, 4), -- pillar
    },
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_data_router_top.png",
    "yatm_data_router_bottom.png",
    "yatm_data_router_side.png",
    "yatm_data_router_side.png",
    "yatm_data_router_side.png",
    "yatm_data_router_side.png",
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
    groups = {},
  },
  data_interface = {
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      --
    end,

    get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)

      local formspec =
        yatm_data_logic.layout_formspec() ..
        yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
        "label[0,0;Port Configuration]"
        -- TODO

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      local needs_refresh = true

      -- TODO

      return true, needs_refresh
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
