local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_server", {
  description = "DATA Server\nSupports a CALL/RESPONSE format for payloads.",

  codex_entry_id = "yatm_data_logic:data_server",

  groups = {
    cracky = nokore.dig_class("copper"),
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- InnerCore
      {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- Rack4
      {-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- Rack3
      {-0.5, -0.1875, -0.5, 0.5, 0, 0.5}, -- Rack2
      {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- Rack1
    }
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_data_server_top.png",
    "yatm_data_server_bottom.png",
    "yatm_data_server_side.png",
    "yatm_data_server_side.png",
    "yatm_data_server_back.png",
    "yatm_data_server_front.png",
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
