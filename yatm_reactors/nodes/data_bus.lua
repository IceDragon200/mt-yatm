local cluster_reactor = assert(yatm.cluster.reactor)
local data_network = yatm.data_network

if not data_network then
  return
end

local function data_bus_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos) .. "\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

for _, variant in ipairs({"hazard", "coolant", "signal"}) do
  local data_bus_reactor_device = {
    kind = "machine",
    groups = {
      data_bus = 1,
      device = 1,
      ["data_bus_" .. variant] = 1,
    },
    default_state = "off",
    states = {
      conflict = "yatm_reactors:data_bus_" .. variant .. "_error",
      error = "yatm_reactors:data_bus_" .. variant .. "_error",
      off = "yatm_reactors:data_bus_" .. variant .. "_off",
      on = "yatm_reactors:data_bus_" .. variant .. "_on",
    }
  }

  yatm_reactors.register_stateful_reactor_node({
    basename = "yatm_reactors:reactor_data_bus_" .. variant,

    description = "Reactor DATA Bus [" .. variant .. "]",
    groups = {
      cracky = nokore.dig_class("copper"),
      yatm_data_device = 1,
    },
    drop = data_bus_reactor_device.states.off,
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant .. "_data_bus_front.off.png"
    },
    paramtype = "none",
    paramtype2 = "facedir",

    reactor_device = data_bus_reactor_device,

    data_network_device = {
      type = "device",
    },
    data_interface = {
      on_load = function (self, pos, node)
      end,

      receive_pdu = function (self, pos, node, dir, port, value)
        --
      end,
    },

    refresh_infotext = data_bus_refresh_infotext,
  }, {
    error = {
      tiles = {
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_" .. variant .. "_data_bus_front.error.png"
      },
    },
    on = {
      tiles = {
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_" .. variant .. "_data_bus_front.on.png"
      },
    }
  })
end
