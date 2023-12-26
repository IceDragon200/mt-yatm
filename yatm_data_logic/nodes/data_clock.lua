local Cuboid = assert(foundation.com.Cuboid)
local is_table_empty = assert(foundation.com.is_table_empty)
local ng = assert(Cuboid.new_fast_node_box)
local string_hex_escape = assert(foundation.com.string_hex_escape)
local data_network = assert(yatm.data_network)

local function scale_value(value, range)
  return math.min(math.max(math.floor(value * range), 0), range)
end

minetest.register_node("yatm_data_logic:data_clock", {
  description = "DATA Clock\nReports the current time of day ranging from 0 to 255 every second",

  codex_entry_id = "yatm_data_logic:data_clock",

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

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_data_clock_top.png",
    "yatm_data_clock_bottom.png",
    "yatm_data_clock_side.png",
    "yatm_data_clock_side.png",
    "yatm_data_clock_side.png",
    "yatm_data_clock_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_int("precision", 1)
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
        local value = 0

        -- precision presents how many bytes are used to represent the time
        -- by default it is 1 byte
        local precision = meta:get_int("precision")

        local timeofday = minetest.get_timeofday()
        local output_data
        if precision == 2 then
          value = scale_value(timeofday, 0xFFFF)
          output_data = string_hex_escape(yatm_data_logic.le_encode_u16(value))
        elseif precision == 3 then
          value = scale_value(timeofday, 0xFFFFFF)
          output_data = string_hex_escape(yatm_data_logic.le_encode_u24(value))
        elseif precision == 4 then
          value = scale_value(timeofday, 0xFFFFFFFF)
          output_data = string_hex_escape(yatm_data_logic.le_encode_u32(value))
        else
          value = scale_value(timeofday, 0xFF)
          output_data = string_hex_escape(yatm_data_logic.le_encode_u8(value))
        end

        yatm_data_logic.emit_output_data_value(pos, output_data)

        meta:set_int("last_timeofday", value)
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
                  label = "Precision",
                  name = "precision",
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
              name = "precision",
              type = "integer",
              meta = true,
              cast = function (self, value, _assigns)
                return math.max(math.min(value, 4), 1)
              end,
            },
          }
        }
      }
    }
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      "Time of Day: " .. meta:get_int("last_timeofday") .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
