--
-- The Wave Generator can output various waveforms as simple data
--
-- Wave generators take a clock pulse (usually a mesecon or data pdu)
-- And then outputs a value based on it's configured wave function
-- The generator can be further configured with the scale, format, and length of the wave
local Waves = assert(foundation.com.Waves)
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local data_network = assert(yatm.data_network)
local string_hex_escape = assert(foundation.com.string_hex_escape)

local mod = yatm_data_logic

local WAVE_SHAPES = {
  "sine",
  "square",
  "triangle",
  "saw",
}

local WAVE_SHAPES_INDEX = {}

for index,name in ipairs(WAVE_SHAPES) do
  WAVE_SHAPES_INDEX[name] = index
end

mod:register_node("data_wave_generator", {
  description = mod.S("DATA Wave Generator"),

  codex_entry_id = "yatm_data_logic:data_wave_generator",

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
      ng(0, 0, 0, 16, 4, 16), -- base
      ng(5, 4, 5,  6,10,  6), -- core
      ng(3, 8, 3, 10, 4, 10), -- head
    },
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_data_wave_generator_top.png",
    "yatm_data_wave_generator_bottom.png",
    "yatm_data_wave_generator_side.png",
    "yatm_data_wave_generator_side.png",
    "yatm_data_wave_generator_side.png",
    "yatm_data_wave_generator_side.png",
  },

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
      local interval_option = meta:get_string("interval_option")
      local wave_shape = meta:get_string("wave_shape")
      local interval = yatm_data_logic.INTERVALS[interval_option]
      local duration = 1

      if interval then
        duration = interval.duration
      end

      -- increment the elapsed with the delta time
      time = (time + dtime) % duration

      local norm = time / duration
      local func = Waves[wave_shape]
      if func then
        local val = (func(norm) + 1) / 2
        local pulse_value = math.min(math.max(math.floor(val * 255), 0), 255)
        local esc = string_hex_escape(string.char(pulse_value))
        meta:set_string("data_pulse_value", esc)
        if yatm_data_logic.emit_output_data(pos, "pulse_value") then
          --
        end
        yatm.queue_refresh_infotext(pos, node)
      end

      meta:set_float("time", time)
    end,

    on_load = function (self, pos, node)
      -- no inputs to bind
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
              component = "dropdown",
              label = "Wave Shape",
              name = "wave_shape",
              type = "string",
              items = WAVE_SHAPES,
              index = WAVE_SHAPES_INDEX,
              meta = true,
            },
            {
              component = "dropdown",
              label = "Interval (Seconds)",
              name = "interval_option",
              type = "string",
              items = yatm_data_logic.INTERVAL_ITEMS,
              index = yatm_data_logic.INTERVAL_NAME_TO_INDEX,
              meta = true,
            },
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
              name = "wave_shape",
              type = "string",
              meta = true,
            },
            {
              component = "field",
              name = "interval_option",
              type = "string",
              meta = true,
            },
          },
          on_fields_change = function (self, pos, _meta, _assigns)
            local node = minetest.get_node(pos)
            yatm.queue_refresh_infotext(pos, node)
          end,
        }
      }
    },
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      "Wave Shape: " .. meta:get_string("wave_shape") .. "\n" ..
      "Interval: " .. meta:get_string("interval_option") .. "\n" ..
      "Pulse Data: " .. meta:get_string("data_pulse_value") .. "\n" ..
      "Time: " .. math.floor(meta:get_float("time")) .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
