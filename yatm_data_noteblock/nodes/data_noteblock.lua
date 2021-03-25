local mod = yatm_data_noteblock
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local is_table_empty = assert(foundation.com.is_table_empty)
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local data_network = assert(yatm.data_network)

-- Just like a mesecon noteblock, except triggered by data events
mod:register_node("data_noteblock", {
  description = mod.S("DATA Note Block"),

  codex_entry_id = "yatm_data_noteblock:data_noteblock",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "none",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 5, 16),
      ng(2, 5, 2, 12,10, 12),
      ng( 0,14, 0, 16, 2, 2),
      ng( 0,14,14, 16, 2, 2),
      ng( 0,14, 0,  2, 2, 16),
      ng(14,14, 0,  2, 2, 16),
    },
  },

  tiles = {
    "yatm_data_noteblock_top.png",
    "yatm_data_noteblock_bottom.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_int("damper", 0)
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

    receive_pdu = function (self, pos, node, dir, local_port, value)
      --print("receive_pdu", minetest.pos_to_string(pos), node.name, dir, local_port, dump(value))
      local meta = minetest.get_meta(pos)
      local payload = string_hex_unescape(value)
      local key = string.byte(payload, 1)
      if key then
        key = key + meta:get_int("offset")
        local damper = meta:get_int("damper")
        yatm.noteblock.play_note(pos, node, key, math.max(0, 127 - damper))
      end
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
              mode = "i",
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
                  label = "Offset",
                  name = "offset",
                  type = "integer",
                  meta = true,
                },
                {
                  component = "field",
                  label = "Damper",
                  name = "damper",
                  type = "integer",
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
              name = "offset",
              type = "integer",
              meta = true,
            },
            {
              component = "field",
              name = "damper",
              type = "integer",
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
})
