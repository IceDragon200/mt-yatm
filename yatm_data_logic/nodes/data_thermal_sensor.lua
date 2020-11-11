local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local string_hex_escape = assert(foundation.com.string_hex_escape)
local is_table_empty = assert(foundation.com.is_table_empty)

local cluster_thermal = yatm.cluster.thermal
if not cluster_thermal then
  return
end

local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_thermal_sensor", {
  description = "Thermal Sensor\nConnects to an existing thermal duct and samples temperature readings.",

  codex_entry_id = "yatm_data_logic:data_thermal_sensor",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_cluster_thermal = 1,
    heatable_device = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16,  4, 16),
      ng(0, 4, 3, 16, 10, 10),
      ng(3, 4, 0, 10, 10, 16),
    },
  },

  tiles = {
    "yatm_data_thermal_sensor_top.png",
    "yatm_data_thermal_sensor_bottom.png",
    "yatm_data_thermal_sensor_side.png",
    "yatm_data_thermal_sensor_side.png",
    "yatm_data_thermal_sensor_side.png",
    "yatm_data_thermal_sensor_side.png",
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
    cluster_thermal:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
    cluster_thermal:schedule_remove_node(pos, node)
  end,

  thermal_interface = {
    groups = {
      thermal_monitor = 1,
    },

    get_heat = function (self, pos, node)
      local meta = minetest.get_meta(pos)
      return meta:get_float("heat")
    end,

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)
      meta:set_float("heat", heat)
      yatm.queue_refresh_infotext(pos, node)
    end,
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
      time = time - dtime

      if time <= 0 then
        time = time + 1

        -- value is a signed 8 bit value here
        local value
        local heat = meta:get_float("heat")
        if heat > 0 then
          value = math.floor(127 * heat / 100)
        elseif heat < 0 then
          value = 127 + math.floor(128 * -heat / 100)
        else
          value = 0
        end

        local output_data = string_hex_escape(string.char(value))
        yatm_data_logic.emit_output_data_value(pos, output_data)

        meta:set_int("last_thermal_level", value)
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
      }
    },
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local heat = math.floor(meta:get_float("heat"))

    local infotext =
      cluster_thermal:get_node_infotext(pos) .. "\n" ..
      data_network:get_infotext(pos) .. "\n" ..
      "Heat: " .. heat .. "\n" ..
      ""

    meta:set_string("infotext", infotext)
  end,
})
