local Cuboid = assert(foundation.com.Cuboid)
local is_table_empty = assert(foundation.com.is_table_empty)
local ng = Cuboid.new_fast_node_box
local string_hex_escape = assert(foundation.com.string_hex_escape)
local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_node_sensor", {
  description = "DATA Node Sensor\nReports various parameters about a neighbour node.",

  codex_entry_id = "yatm_data_logic:data_node_sensor",

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
      ng(0, 0, 0, 16, 4, 16),
      ng(3, 4, 3, 10, 1, 10),
    },
  },

  tiles = {
    "yatm_data_node_sensor_top.png",
    "yatm_data_node_sensor_bottom.png",
    "yatm_data_node_sensor_side.png",
    "yatm_data_node_sensor_side.png",
    "yatm_data_node_sensor_side.png",
    "yatm_data_node_sensor_side.png",
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
    groups = {
      updatable = 1,
    },
  },
  data_interface = {
    update = function (self, pos, node, dtime)
      local meta = minetest.get_meta(pos)

      local time = meta:get_float("time")
      time = time - dtime

      if time <= 0 then
        time = time + 1

        local value = 0 -- TODO: sample data

        local output_data = string_hex_escape(string.char(value))
        yatm_data_logic.emit_output_data_value(pos, output_data)

        -- TODO: store coords of last sampled entity
        yatm.queue_refresh_infotext(pos, node)
      end

      meta:set_float("time", time)
    end,

    on_load = function (self, pos, node)
      --
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
        "label[0,0;Port Configuration]" ..
        yatm_data_logic.render_io_port_formspec(pos, meta, "o")

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      local needs_refresh = false

      local _ichg, ochg = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "o")

      if not is_table_empty(ochg) then
        needs_refresh = true
      end

      return true, needs_refresh
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      -- TODO: report last seen entity
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
