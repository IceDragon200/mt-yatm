local cluster_reactor = assert(yatm.cluster.reactor)

local function fuel_rod_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local fuel_rod_open_reactor_device = {
  kind = "fuel_rod",

  groups = {
    fuel_rod_casing = 1,
    fuel_rod_open = 1,
    device = 1,
  },

  default_state = "off",

  states = {
    conflict = "yatm_reactors:fuel_rod_case_open",
    error = "yatm_reactors:fuel_rod_case_open",
    off = "yatm_reactors:fuel_rod_case_open",
    on = "yatm_reactors:fuel_rod_case_open",
  }
}

yatm_reactors.register_reactor_node("yatm_reactors:fuel_rod_case_open", {
  description = "Fuel Rod Case (Unoccupied)",
  groups = {
    cracky = 1
  },

  drop = fuel_rod_open_reactor_device.states.off,

  tiles = {
    "yatm_reactor_fuel_rod_case.open.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  reactor_device = fuel_rod_open_reactor_device,

  refresh_infotext = fuel_rod_refresh_infotext,
})

local function update_fuel_rod(pos, node, state, dtime)
  -- todo consume fuel rod
end

for _, variant in ipairs({"uranium", "plutonium", "radium", "redranium"}) do
  local fuel_rod_reactor_device = {
    kind = "machine",

    groups = {
      fuel_rod = 1,
      ["fuel_rod_" .. variant] = 1,
      device = 1,
    },

    default_state = "off",

    states = {
      conflict = "yatm_reactors:fuel_rod_case_" .. variant .. "_error",
      error = "yatm_reactors:fuel_rod_case_" .. variant .. "_error",
      off = "yatm_reactors:fuel_rod_case_" .. variant .. "_off",
      on = "yatm_reactors:fuel_rod_case_" .. variant .. "_on",
    }
  }

  fuel_rod_reactor_device.update_fuel_rod = update_fuel_rod

  yatm_reactors.register_stateful_reactor_node({
    basename = "yatm_reactors:fuel_rod_case_" .. variant,

    description = "Reactor Fuel Rod (" .. variant .. ")",

    groups = {
      cracky = 1,
      nuclear_fuel_rod = 1,
      ["nuclear_fuel_rod_" .. variant] = 1,
    },

    nuclear_fuel_rod_type = variant,

    drop = fuel_rod_reactor_device.states.off,

    tiles = {
      "yatm_reactor_fuel_rod_case.closed." .. variant .. ".png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
    },

    paramtype = "none",
    paramtype2 = "facedir",

    reactor_device = fuel_rod_reactor_device,

    refresh_infotext = fuel_rod_refresh_infotext,
  }, {
    error = {
      tiles = {
        "yatm_reactor_fuel_rod_case.closed." .. variant .. ".png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
      },
    },
    on = {
      tiles = {
        "yatm_reactor_fuel_rod_case.closed." .. variant .. ".png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
      },
    },
  })
end
