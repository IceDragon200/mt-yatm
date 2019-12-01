--
-- Comparator Data Hubs
--
-- Comparator's take data input and then compare them before emitting a different payload depending on whether it was true or false.
local data_network = assert(yatm.data_network)

yatm.register_stateful_node("yatm_data_logic:data_comparator", {
  base_description = "Data Comparator",

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
      yatm_core.Cuboid:new(3, 4, 3, 10, 1, 10):fast_node_box(),
    },
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
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
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      local meta = minetest.get_meta(pos)
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

      yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "io")

      return true
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  --
  -- Normal Mode
  --
  equal_to = {
    description = "Data Comparator [Equal To]",

    tiles = {
      "yatm_data_comparator_top.equal_to.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },
  },
  not_equal_to = {
    description = "Data Comparator [Not Equal To]",

    tiles = {
      "yatm_data_comparator_top.not_equal_to.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },
  },
  greater_than = {
    description = "Data Comparator [Greater Than]",

    tiles = {
      "yatm_data_comparator_top.greater_than.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },
  },
  greater_than_or_equal_to = {
    description = "Data Comparator [Greater Than or Equal To]",

    tiles = {
      "yatm_data_comparator_top.greater_than_or_equal_to.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },
  },
  less_than = {
    description = "Data Comparator [Less Than]",

    tiles = {
      "yatm_data_comparator_top.less_than.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },
  },
  less_than_or_equal_to = {
    description = "Data Comparator [Less Than or Equal To]",

    tiles = {
      "yatm_data_comparator_top.less_than_or_equal_to.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },
  },
})
