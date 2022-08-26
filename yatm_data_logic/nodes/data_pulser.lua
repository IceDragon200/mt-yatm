local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local sounds = assert(yatm.sounds)
local data_network = assert(yatm.data_network)
local is_table_empty = assert(foundation.com.is_table_empty)
local fspec = assert(foundation.com.formspec.api)

local function on_node_pulsed(pos, node)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.next_step then
    local new_node = {
      name = nodedef.next_step,
      param1 = node.param1,
      param2 = node.param2,
    }

    minetest.swap_node(pos, new_node)
    data_network:upsert_member(pos, new_node)
  end
end

yatm.register_stateful_node("yatm_data_logic:data_pulser", {
  basename = "yatm_data_logic:data_pulser",
  description = "DATA Pulser",

  codex_entry_id = "yatm_data_logic:data_pulser",

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
    "yatm_data_pulser_top.png",
    "yatm_data_pulser_bottom.png",
    "yatm_data_pulser_side.png",
    "yatm_data_pulser_side.png",
    "yatm_data_pulser_side.png",
    "yatm_data_pulser_side.png",
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
        if yatm_data_logic.emit_output_data(pos, "pulse") then
          sounds:play("blip1", { pos = pos, max_hear_distance = 32, pitch_variance = 0.025 })
        end
        on_node_pulsed(pos, node)

        local interval_option = meta:get_string("interval_option")
        local duration = 1
        local interval = yatm_data_logic.INTERVALS[interval_option]
        if interval then
          duration = interval.duration
        end
        time = time + duration
      end

      meta:set_float("time", time)
    end,

    on_load = function (self, pos, node)
      -- pulsers don't need to bind listeners of any sorts
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
                  component = "dropdown",
                  label = "Interval",
                  name = "interval_option",
                  type = "string",
                  meta = true,
                  items = yatm_data_logic.INTERVAL_ITEMS,
                  index = yatm_data_logic.INTERVAL_NAME_TO_INDEX,
                },
                {
                  component = "field",
                  label = "Data on Pulse",
                  name = "data_pulse",
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
              name = "interval_option",
              type = "string",
              meta = true,
            },
            {
              component = "field",
              name = "data_pulse",
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
}, {
  off = {
    next_step = "yatm_data_logic:data_pulser_step_0",
  },
  step_0 = {
    next_step = "yatm_data_logic:data_pulser_step_1",
    tiles = {
      "yatm_data_pulser_top.pulse.0.png",
      "yatm_data_pulser_bottom.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
    },
    use_texture_alpha = "opaque",
  },
  step_1 = {
    next_step = "yatm_data_logic:data_pulser_step_0",
    tiles = {
      "yatm_data_pulser_top.pulse.1.png",
      "yatm_data_pulser_bottom.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
    },
    use_texture_alpha = "opaque",
  }
})
