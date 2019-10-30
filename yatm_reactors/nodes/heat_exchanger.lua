local cluster_reactor = assert(yatm.cluster.reactor)
local cluster_thermal = assert(yatm.cluster.thermal)

local function heat_exchanger_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos) .. "\n" ..
    cluster_thermal:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function heat_exchanger_transfer_heat(pos, node)
  --
end

local heat_exchanger_reactor_device = {
  kind = "heat_exchanger",

  groups = {
    heat_exchanger = 1,
    device = 1,
  },

  default_state = "off",

  states = {
    conflict = "yatm_reactors:heat_exchanger_error",
    error = "yatm_reactors:heat_exchanger_error",
    off = "yatm_reactors:heat_exchanger_off",
    on = "yatm_reactors:heat_exchanger_on",
  }
}

yatm_reactors.register_stateful_reactor_node({
  basename = "yatm_reactors:heat_exchanger",

  description = "Reactor Heat Exchanger",
  groups = {
    cracky = 1,
    heater_device = 1,
    yatm_cluster_thermal = 1
  },

  drop = heat_exchanger_reactor_device.states.off,

  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_heat_exchanger_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  reactor_device = heat_exchanger_reactor_device,

  refresh_infotext = heat_exchanger_refresh_infotext,

  transfer_heat = heat_exchanger_transfer_heat,
}, {
  error = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_heat_exchanger_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_heat_exchanger_front.on.png"
    },
  },
})
