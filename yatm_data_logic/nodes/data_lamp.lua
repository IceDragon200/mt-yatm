local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local is_table_empty = assert(foundation.com.is_table_empty)
local number_round = assert(foundation.com.number_round)
local data_network = assert(yatm.data_network)

local lamp_levels = {}

local lamp_sounds = yatm.node_sounds:build("glass")

for i = 0,13 do
  local digits = foundation.com.string_pad_leading(tostring(i), 2, "0")

  local name = "yatm_data_logic:data_levelled_lamp_" .. digits
  lamp_levels[i] = name

  local groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  }

  if i > 0 then
    groups.not_in_creative_inventory = 1
  end

  minetest.register_node(name, {
    basename = "yatm_data_logic:data_levelled_lamp",

    base_description = "DATA Levelled Lamp",
    description = "DATA Levelled Lamp (" .. i .. ")",

    codex_entry_id = "yatm_data_logic:data_levelled_lamp",

    groups = groups,

    sound = lamp_sounds,
    light_source = i,

    paramtype = "light",
    paramtype2 = "facedir",

    drops = "yatm_data_logic:data_levelled_lamp_00",

    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 0, 16, 4, 16),
        ng(2, 4, 2, 12, 3, 12),
      },
    },

    tiles = {
      "yatm_data_lamp_top_"..digits..".png",
      "yatm_data_lamp_bottom_"..digits..".png",
      "yatm_data_lamp_side_"..digits..".png",
      "yatm_data_lamp_side_"..digits..".png",
      "yatm_data_lamp_side_"..digits..".png",
      "yatm_data_lamp_side_"..digits..".png",
    },
    use_texture_alpha = "opaque",

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
        yatm_data_logic.mark_all_inputs_for_active_receive(pos)
      end,

      receive_pdu = function (self, pos, node, dir, port, value)
        local str = string_hex_unescape(value)
        local byte = string.byte(str, 1)
        local level = number_round(byte * 13 / 255)
        local new_name = lamp_levels[level]

        if new_name ~= name then
          local new_node = {
            name = new_name,
            param1 = node.param1,
            param2 = node.param2,
          }
          minetest.swap_node(pos, new_node)
          yatm.queue_refresh_infotext(pos, new_node)
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
              {component = "io_ports", mode = "i"}
            }
          },
        }
      }
    },

    refresh_infotext = function (pos)
      local meta = minetest.get_meta(pos)
      local infotext =
        "Light Level: " .. i .. "\n" ..
        data_network:get_infotext(pos)

      meta:set_string("infotext", infotext)
    end,
  })
end
