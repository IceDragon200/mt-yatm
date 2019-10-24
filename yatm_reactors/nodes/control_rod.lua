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
    control_rod = 1,
    device = 1,
  },

  default_state = "off",

  states = {
    conflict = "yatm_reactors:control_rod_case_error",
    error = "yatm_reactors:control_rod_case_error",
    off = "yatm_reactors:control_rod_case_off",
    on = "yatm_reactors:control_rod_case_on",
    idle = "yatm_reactors:control_rod_case_idle",
  }
}

yatm_reactors.register_stateful_reactor_node({
  description = "Control Rod",
  groups = {cracky = 1},

  drop = control_rod_open_reactor_device.states.off,

  tiles = {
    "yatm_reactor_control_rod_top.off.png",
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
}, {
  error = {
    tiles = {
      "yatm_reactor_control_rod_top.error.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
    },
  },

  on = {
    tiles = {
      "yatm_reactor_control_rod_top.on.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
    },
  },

  idle = {
    tiles = {
      "yatm_reactor_control_rod_top.idle.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
    },
  }
})
