local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local is_table_empty = assert(foundation.com.is_table_empty)
local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_buffer", {
  description = "DATA Buffer",

  codex_entry_id = "yatm_data_logic:data_buffer",

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
      ng(0, 0, 0, 16, 4, 16),
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
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      local meta = minetest.get_meta(pos)
      yatm_data_logic.emit_output_data(pos, "buffered_value")
      meta:set_string("data_buffered_value", value)
    end,

    get_programmer_formspec = {
      default_tab = "ports",
      tabs = {
        {
          tab_id = "ports",
          title = "Ports",
          header = "Port Configuration",
          render = {
            {
              component = "io_ports",
              mode = "io",
            }
          },
        },
      }
    },

    receive_programmer_fields = {
      tabbed = true, -- notify the solver that tabs are in use
      tabs = {
        {
          components = {
            {component = "io_ports", mode = "io"}
          }
        },
      }
    }
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
