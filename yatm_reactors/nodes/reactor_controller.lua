local cluster_reactor = assert(yatm.cluster.reactor)

local function reactor_controller_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local reactor_controller_reactor_device = {
  kind = "controller",

  groups = {
    controller = 1,
  },

  default_state = "off",

  states = {
    conflict = "yatm_reactors:reactor_controller_error",
    error = "yatm_reactors:reactor_controller_error",
    off = "yatm_reactors:reactor_controller_off",
    on = "yatm_reactors:reactor_controller_on",
  }
}

yatm_reactors.register_stateful_reactor_node({
  description = "Reactor Controller",

  groups = {cracky = 1},

  drop = reactor_controller_reactor_device.states.off,

  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_controller_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  reactor_device = reactor_controller_reactor_device,

  refresh_infotext = reactor_controller_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_controller_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_controller_front.on.png"
    },
  }
})
