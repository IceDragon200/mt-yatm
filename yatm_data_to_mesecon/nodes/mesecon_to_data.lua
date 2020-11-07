local Directions = assert(foundation.com.Directions)
local is_table_empty = assert(foundation.com.is_table_empty)
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local data_network = assert(yatm.data_network)

local function mesecon_rules(node)
  local result = {}
  local i = 1
  for _, dir in ipairs(Directions.DIR4) do
    local new_dir = Directions.facedir_to_face(node.param2, dir)
    result[i] = Directions.DIR6_TO_VEC3[new_dir]
    i = i + 1
  end
  return result
end

yatm.register_stateful_node("yatm_data_to_mesecon:mesecon_to_data", {
  --description = "Mesecon To Data",
  description = "Mesecon Switcher",

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
      ng(3, 4, 3, 10, 2, 10),
    },
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
  },
  data_interface = {
    on_load = function (self, pos, node)
      --
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
                  label = "Data (ON)",
                  name = "data_on",
                  type = "string",
                  meta = true,
                },
                {
                  component = "field",
                  label = "Data (OFF)",
                  name = "data_off",
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
              name = "data_on",
              type = "string",
              meta = true,
            },
            {
              component = "field",
              name = "data_off",
              type = "string",
              meta = true,
            }
          }
        }
      }
    },
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  off = {
    mesecons = {
      effector = {
        rules = mesecon_rules,

        action_on = function (pos, node)
          node.name = "yatm_data_to_mesecon:mesecon_to_data_on"
          minetest.swap_node(pos, node)
          yatm_data_logic.emit_output_data(pos, "on")
        end,
      },
    },

    tiles = {
      "yatm_data_mesecon_top.mesecon.off.png",
      "yatm_data_mesecon_bottom.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
    },
  },
  on = {
    groups = {
      cracky = 1,
      data_programmable = 1,
      yatm_data_device = 1,
      not_in_creative_inventory = 1,
    },

    mesecons = {
      effector = {
        rules = mesecon_rules,

        action_off = function (pos, node)
          node.name = "yatm_data_to_mesecon:mesecon_to_data_off"
          minetest.swap_node(pos, node)
          yatm_data_logic.emit_output_data(pos, "off")
        end,
      },
    },

    tiles = {
      "yatm_data_mesecon_top.mesecon.on.png",
      "yatm_data_mesecon_bottom.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
    },
  }
})
