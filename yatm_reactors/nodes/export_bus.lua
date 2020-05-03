local cluster_reactor = assert(yatm.cluster.reactor)

local function export_bus_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local variants = {
  {"hazard", "Hazard"},
  {"coolant", "Coolant"},
  {"signal", "Signal"},
}

for _, variant_pair in ipairs(variants) do
  local variant_basename = variant_pair[1]
  local variant_name = variant_pair[2]

  local export_bus_reactor_device = {
    kind = "export_bus",

    groups = {
      export_bus = 1,
    },

    default_state = "off",

    states = {
      conflict = "yatm_reactors:export_bus_" .. variant_basename .. "_error",
      error = "yatm_reactors:export_bus_" .. variant_basename .. "_error",
      off = "yatm_reactors:export_bus_" .. variant_basename .. "_off",
      on = "yatm_reactors:export_bus_" .. variant_basename .. "_on",
    }
  }

  local groups = {
    cracky = 1
  }

  if variant_basename == "hazard" or variant_basename == "coolant" then
    groups.fluid_interface_out = 1
  elseif variant_basename == "signal" then
    groups.mesecon_interface_out = 1
  end

  yatm_reactors.register_stateful_reactor_node({
    basename = "yatm_reactors:reactor_export_bus",

    description = "Reactor Export Bus (" .. variant_name .. ")",

    groups = groups,

    drop = export_bus_reactor_device.states.off,

    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant_basename .. "_export_bus_front.off.png"
    },

    paramtype = "none",
    paramtype2 = "facedir",

    reactor_device = export_bus_reactor_device,

    refresh_infotext = export_bus_refresh_infotext,
  }, {
    error = {

      tiles = {
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_" .. variant_basename .. "_export_bus_front.error.png"
      },
    },
    on = {
      tiles = {
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_" .. variant_basename .. "_export_bus_front.on.png"
      },
    }
  })
end
