local cluster_reactor = assert(yatm.cluster.reactor)

local function control_rod_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local control_rod_open_reactor_device = {
  kind = "control_rod",

  groups = {
    control_rod_casing = 1,
    control_rod_open = 1,
    device = 1,
  },

  default_state = "off",

  states = {
    conflict = "yatm_reactors:control_rod_open",
    error = "yatm_reactors:control_rod_open",
    off = "yatm_reactors:control_rod_open",
    on = "yatm_reactors:control_rod_open",
  }
}

yatm_reactors.register_reactor_node("yatm_reactors:control_rod_open", {
  description = "Control Rod (Unoccupied)",
  groups = {cracky = 1},

  drop = control_rod_open_reactor_device.states.off,

  tiles = {
    "yatm_reactor_control_rod.open.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  reactor_device = control_rod_open_reactor_device,

  refresh_infotext = control_rod_refresh_infotext,
})

for _, variant in ipairs({"uranium", "plutonium", "radium"}) do
  local control_rod_reactor_device = {
    kind = "machine",

    groups = {
      control_rod = 1,
      ["control_rod_" .. variant] = 1,
      device = 1,
    },

    default_state = "off",

    states = {
      conflict = "yatm_reactors:control_rod_close_" .. variant .. "_error",
      error = "yatm_reactors:control_rod_close_" .. variant .. "_error",
      off = "yatm_reactors:control_rod_close_" .. variant .. "_off",
      on = "yatm_reactors:control_rod_close_" .. variant .. "_on",
    }
  }

  yatm_reactors.register_stateful_reactor_node({
    description = "Reactor Control Rod (" .. variant .. ")",

    groups = {cracky = 1},

    drop = control_rod_reactor_device.states.off,

    tiles = {
      "yatm_reactor_control_rod.close." .. variant .. ".png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",

    reactor_device = control_rod_reactor_device,

    refresh_infotext = control_rod_refresh_infotext,
  }, {
    error = {
      tiles = {
        "yatm_reactor_control_rod.close." .. variant .. ".png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
      },
    },
    on = {
      tiles = {
        "yatm_reactor_control_rod.close." .. variant .. ".png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png^[transformFX",
        "yatm_reactor_casing.plain.png",
        "yatm_reactor_casing.plain.png",
      },
    },
  })
end
