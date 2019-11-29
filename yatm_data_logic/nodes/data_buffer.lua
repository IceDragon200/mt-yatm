local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_buffer", {
  description = "Data Buffer",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 4, 16):fast_node_box(),
    },
  },

  tiles = {
    "yatm_data_buffer_top.png",
    "yatm_data_buffer_bottom.png",
    "yatm_data_buffer_side.png",
    "yatm_data_buffer_side.png",
    "yatm_data_buffer_side.png",
    "yatm_data_buffer_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)

    meta:set_string("data_buffered_value", "")

    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (pos, node, dir, port, value)
      local meta = minetest.get_meta(pos)
      yatm_data_logic.emit_output_data(pos, "buffered_value")
      meta:set_string("data_buffered_value", value)
    end,

    get_programmer_formspec = function (self, pos, clicker, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)

      local formspec =
        "size[8,9]" ..
        "label[0,0;Port Configuration]" ..
        yatm_data_logic.get_io_port_formspec(pos, meta, "io")

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "io")

      if not yatm_core.is_table_empty(inputs_changed) then
        yatm_data_logic.unmark_all_receive(assigns.pos)
        yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
      end

      return true
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
