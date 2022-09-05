local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local is_table_empty = assert(foundation.com.is_table_empty)
local data_network = assert(yatm.data_network)

local ASCII_TABLE = {}
local SPACE = string.byte(" ")
for i = 0,255 do
  -- remap everything to whitespace
  ASCII_TABLE[i] = SPACE
end

for i = 33,95 do
  -- supported characters
  ASCII_TABLE[i] = i
end

for i = 97,122 do
  -- remap lower case to uppercase
  ASCII_TABLE[i] = i - 32
end

-- the remaining characters that can be mapped
ASCII_TABLE[123] = 123
ASCII_TABLE[124] = 124
ASCII_TABLE[125] = 125

-- everything else will be whitespace

local states = {}

for ascii_code, new_ascii_code in pairs(ASCII_TABLE) do
  if not states[new_ascii_code] then
    local groups = {
      cracky = nokore.dig_class("copper"),
      data_programmable = 1,
      yatm_data_device = 1,
    }

    local top_tile
    if new_ascii_code ~= SPACE then
      top_tile = "yatm_data_char_display_top.png^" .. "yatm_yatm_blocky_font_" .. new_ascii_code .. ".png"
      groups.not_in_creative_inventory = 1
    else
      top_tile = "yatm_data_char_display_top.png"
    end

    states[new_ascii_code] = {
      description = "ASCII Display [" .. string.char(new_ascii_code) .. "]",

      groups = groups,

      ascii_char = string.char(new_ascii_code),

      tiles = {
        top_tile,
        "yatm_data_char_display_bottom.png",
        "yatm_data_char_display_side.png",
        "yatm_data_char_display_side.png",
        "yatm_data_char_display_side.png",
        "yatm_data_char_display_side.png",
      },
      use_texture_alpha = "clip",
    }
  end
end

yatm.register_stateful_node("yatm_data_display:ascii_display", {
  codex_entry_id = "yatm_data_display:ascii_display",

  base_description = "ASCII Display",

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 4, 16),
    },
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_place_node = assert(foundation.com.Directions.facedir_wallmount_after_place_node),

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
      local meta = minetest.get_meta(pos)

      local str = string_hex_unescape(value)
      local byte = string.byte(str)
      if byte then
        local new_name = "yatm_data_display:ascii_display_" .. ASCII_TABLE[byte]

        if new_name ~= node.name then
          local new_node = {
            name = new_name,
            param1 = node.param1,
            param2 = node.param2,
          }
          minetest.swap_node(pos, new_node)
          data_network:upsert_member(pos, new_node)
          yatm.queue_refresh_infotext(pos, new_node)
        end
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
      }
    },

    receive_programmer_fields = {
      tabbed = true, -- notify the solver that tabs are in use
      tabs = {
        {
          components = {
            {
              component = "io_ports",
              mode = "i",
            }
          }
        },
      },
    },
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]

    local infotext =
      "ASCII Display: " .. nodedef.ascii_char .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, states)

-- trash the old states, we don't need it anymore
states = nil
