--
-- The Wave Generator can output various waveforms as simple data
--
-- Wave generators take a clock pulse (usually a mesecon or data pdu)
-- And then outputs a value based on it's configured wave function
-- The generator can be further configured with the scale, format, and length of the wave
local mod = yatm_data_logic
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local data_network = assert(yatm.data_network)
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local Groups = foundation.com.Groups

yatm.register_stateful_node("yatm_data_logic:data_level_display_decor_panel", {
  basename = "yatm_data_logic:data_level_display_decor_panel",

  base_description = "DATA Level Display Decor Panel",

  codex_entry_id = "yatm_data_logic:data_level_display",

  groups = {
    cracky = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 16, 1),
    },
  },
}, {
  ["0a"] = {
    description = "DATA Level Display Decor Panel [Style 0A]",

    tiles = {
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0.bottom.png",
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0a.png",
      "yatm_data_level_display_panel0a.png",
    },
  },

  ["0b"] = {
    description = "DATA Level Display Decor Panel [Style 0B]",

    tiles = {
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0.bottom.png",
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0b.png",
      "yatm_data_level_display_panel0b.png",
    },
  },

  ["0c"] = {
    description = "DATA Level Display Decor Panel [Style 0C]",

    tiles = {
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0.bottom.png",
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0.top.png",
      "yatm_data_level_display_panel0c.png",
      "yatm_data_level_display_panel0c.png",
    },
  },

  ["1a"] = {
    description = "DATA Level Display Decor Panel [Style 1A]",

    tiles = {
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.bottom.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1a.png",
      "yatm_data_level_display_panel1a.png",
    },
  },

  ["1b"] = {
    description = "DATA Level Display Decor Panel [Style 1B]",

    tiles = {
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.bottom.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1b.png",
      "yatm_data_level_display_panel1b.png",
    },
  },

  ["1c"] = {
    description = "DATA Level Display Decor Panel [Style 1C]",

    tiles = {
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.bottom.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1c.png",
      "yatm_data_level_display_panel1c.png",
    },
  },

  ["2a"] = {
    description = "DATA Level Display Decor Panel [Style 2A]",

    tiles = {
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel1.top.png",
      "yatm_data_level_display_panel2a.png",
      "yatm_data_level_display_panel2a.png",
    },
  },
})

yatm.register_stateful_node("yatm_data_logic:data_level_display", {
  base_description = mod.S("DATA Level Display"),

  codex_entry_id = "yatm_data_logic:data_level_display",

  groups = {
    cracky = 1,
    data_level_display = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  connects_to = {"group:data_level_display"},

  paramtype = "light",
  paramtype2 = "glasslikeliquidlevel",

  drawtype = "glasslike_framed",
  tiles = {
    "yatm_data_level_display_enclosure.png",
    "yatm_data_level_display_blank.png",
  },
  special_tiles = {
  },

  is_ground_content = false,
  sunlight_propagates = true,
  sounds = yatm.node_sounds:build("glass"),

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
    groups = {
    },
  },
  data_interface = {
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      local blob = string_hex_unescape(value)
      local byte = string.byte(blob, 1)

      local p = vector.new(pos)
      local max_reach = 0
      while max_reach < 16 do
        local tnode = minetest.get_node_or_nil(p)
        if tnode then
          local nodedef = minetest.registered_nodes[tnode.name]
          if nodedef and Groups.has_group(nodedef, "data_level_display") then
            max_reach = max_reach + 1
            p.y = p.y + 1
          else
            break
          end
        else
          break
        end
      end

      if max_reach > 0 then
        local max_level = max_reach * 63
        local level = math.max(math.min(math.floor(byte * max_level / 255), max_level), 0)

        local p = vector.new(pos)
        local i = 0
        while i < max_reach do
          local tnode = minetest.get_node_or_nil(p)
          local param2 = math.min(level, 63)
          if tnode.param2 ~= param2 then
            tnode.param2 = param2
            minetest.swap_node(p, tnode)
            yatm.queue_refresh_infotext(vector.new(p), tnode)
          end
          p.y = p.y + 1
          level = math.max(level - 63, 0)
          i = i + 1
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
            {component = "io_ports", mode = "i"}
          }
        },
      }
    },
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    local infotext =
      "Level: " .. node.param2 .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  heating = {
    description = mod.S("DATA Level Display [Heating Style]"),

    special_tiles = {
      {
        name = "yatm_data_level_display_liquid_heating.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
    },
  },
  cooling = {
    description = mod.S("DATA Level Display [Cooling Style]"),

    special_tiles = {
      {
        name = "yatm_data_level_display_liquid_cooling.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
    },
  },
  nuclear = {
    description = mod.S("DATA Level Display [Nuclear Style]"),

    special_tiles = {
      {
        name = "yatm_data_level_display_liquid_nuclear.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
    },
  }
})
