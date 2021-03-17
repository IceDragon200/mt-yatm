--
-- The Wave Generator can output various waveforms as simple data
--
-- Wave generators take a clock pulse (usually a mesecon or data pdu)
-- And then outputs a value based on it's configured wave function
-- The generator can be further configured with the scale, format, and length of the wave
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local data_network = assert(yatm.data_network)

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
    groups = {},
  },
  data_interface = {
    on_load = function (self, pos, node)
      -- rebind all inputs
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
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
              name = "wave_shape",
              type = "string",
              meta = true,
            },
          }
        }
      }
    },
  },
})
