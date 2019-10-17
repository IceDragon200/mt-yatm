local data_bus_data_interface = {}
function data_bus_data_interface:receive_pdu(pos, node, port, value)
end

for _, variant in ipairs({"hazard", "coolant", "signal"}) do
  local data_bus_yatm_network = {
    kind = "machine",
    groups = {
      reactor = 1,
      reactor_data_bus = 1,
    },
    default_state = "off",
    states = {
      conflict = "yatm_reactors:data_bus_" .. variant .. "_error",
      error = "yatm_reactors:data_bus_" .. variant .. "_error",
      off = "yatm_reactors:data_bus_" .. variant .. "_off",
      on = "yatm_reactors:data_bus_" .. variant .. "_on",
    }
  }

  yatm.devices.register_stateful_network_device({
    description = "Reactor Data Bus (" .. variant .. ")",
    groups = {cracky = 1, yatm_data_device = 1},
    drop = data_bus_yatm_network.states.off,
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant .. "_data_bus_front.off.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",

    yatm_network = data_bus_yatm_network,

    data_network_device = {
      type = "device",
    },
    data_interface = data_bus_data_interface,
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
