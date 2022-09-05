local cluster_reactor = assert(yatm.cluster.reactor)

local function import_bus_refresh_infotext(pos, node)
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

  local import_bus_reactor_device = {
    kind = "import_bus",

    groups = {
      import_bus = 1,
      device = 1,
    },

    default_state = "off",

    states = {
      conflict = "yatm_reactors:import_bus_" .. variant_basename .. "_error",
      error = "yatm_reactors:import_bus_" .. variant_basename .. "_error",
      off = "yatm_reactors:import_bus_" .. variant_basename .. "_off",
      on = "yatm_reactors:import_bus_" .. variant_basename .. "_on",
    }
  }

  local groups = {
    cracky = nokore.dig_class("copper"),
  }
  if variant_basename == "hazard" or variant_basename == "coolant" then
    groups.fluid_interface_in = 1
  elseif variant_basename == "signal" then
    groups.mesecon_interface_in = 1
  end

  yatm_reactors.register_stateful_reactor_node({
    basename = "yatm_reactors:import_bus",

    description = "Reactor Import Bus (" .. variant_name .. ")",

    codex_entry_id = "yatm_reactors:import_bus",

    groups = groups,
    drop = import_bus_reactor_device.states.off,

    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant_basename .. "_import_bus_front.off.png"
    },
    paramtype = "none",
    paramtype2 = "facedir",

    reactor_device = import_bus_reactor_device,

    refresh_infotext = import_bus_refresh_infotext,
  }, {
    error = {
      tiles = {
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_" .. variant_basename .. "_import_bus_front.error.png"
      },
    },
    on = {
      tiles = {
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_" .. variant_basename .. "_import_bus_front.on.png"
      },
    },
  })
end
