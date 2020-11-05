local Cuboid = assert(foundation.com.Cuboid)
local is_table_empty = assert(foundation.com.is_table_empty)
local ng = Cuboid.new_fast_node_box
local sounds = assert(yatm_core.sounds)
local data_network = assert(yatm.data_network)

yatm.register_stateful_node("yatm_data_logic:data_toggle_button", {
  description = "Data Toggle Button",

  codex_entry_id = "yatm_data_logic:data_toggle_button",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (self, pos, node)
      -- toggles don't need to bind listeners of any sorts
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      --
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
              mode = "o",
            }
          },
        },
        {
          tab_id = "data",
          title = "Data",
          header = "Data Configuration",
          render = {
            {
              component = "row",
              items = {
                {
                  component = "field",
                  label = "Data (Left/0)",
                  name = "data_left",
                  type = "string",
                  meta = true,
                },
                {
                  component = "field",
                  label = "Data (Right/1)",
                  name = "data_right",
                  type = "string",
                  meta = true,
                }
              }
            }
          }
        }
      }
    },

    receive_programmer_fields = {
      tabbed = true, -- notify the solver that tabs are in use
      tabs = {
        {
          components = {
            {component = "io_ports", mode = "o"}
          }
        },
        {
          components = {
            {
              component = "field",
              name = "data_left",
              type = "string",
              meta = true,
            },
            {
              component = "field",
              name = "data_right",
              type = "string",
              meta = true,
            }
          }
        }
      }
    }
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,
}, {
  left = {
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 0, 16, 4, 16),
        ng(2, 4, 3,  6, 2, 10),
      },
    },

    tiles = {
      "yatm_data_toggle_button_top.left.png",
      "yatm_data_toggle_button_bottom.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_front.left.png^[transformFX",
      "yatm_data_toggle_button_front.left.png",
    },

    on_rightclick = function (pos, node, clicker)
      sounds:play("button_click", { pos = pos, max_hear_distance = 32 })
      node.name = "yatm_data_logic:data_toggle_button_right"
      minetest.swap_node(pos, node)

      yatm_data_logic.emit_output_data(pos, "left")
    end,
  },

  right = {
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 0, 16, 4, 16),
        ng(8, 4, 3,  6, 2, 10),
      },
    },

    tiles = {
      "yatm_data_toggle_button_top.right.png",
      "yatm_data_toggle_button_bottom.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_front.right.png^[transformFX",
      "yatm_data_toggle_button_front.right.png",
    },

    on_rightclick = function (pos, node, clicker)
      sounds:play("button_click", { pos = pos, max_hear_distance = 32 })
      node.name = "yatm_data_logic:data_toggle_button_left"
      minetest.swap_node(pos, node)

      yatm_data_logic.emit_output_data(pos, "right")
    end,
  },
})
