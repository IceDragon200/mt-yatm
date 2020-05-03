local cluster_reactor = assert(yatm.cluster.reactor)
local cluster_energy = yatm.cluster.energy

if not cluster_energy then
  return
end

local function energy_bus_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local energy_bus_reactor_device = {
  kind = "energy_bus",
  groups = {
    energy_bus = 1,
    device = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_reactors:energy_bus_error",
    error = "yatm_reactors:energy_bus_error",
    off = "yatm_reactors:energy_bus_off",
    on = "yatm_reactors:energy_bus_on",
    idle = "yatm_reactors:energy_bus_idle",
  }
}

local energy_bus_yatm_network = {
  kind = "reactor_energy_bus",

  groups = {
    energy_producer = 1,
  },

  default_state = energy_bus_reactor_device.default_state,
  states = energy_bus_reactor_device.states,

  energy = {}
}

function energy_bus_yatm_network.energy.produce_energy(pos, node, dtime, ot)
  return 0
end

yatm_reactors.register_stateful_reactor_node({
  basename = "yatm_reactors:reactor_energy_bus",

  description = "Reactor Energy Bus",
  groups = {
    cracky = 1,
    yatm_energy_device = 1,
    yatm_cluster_energy = 1,
  },
  drop = energy_bus_reactor_device.states.off,
  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_energy_bus_front.off.png"
  },
  paramtype = "none",
  paramtype2 = "facedir",

  reactor_device = energy_bus_reactor_device,
  yatm_network = energy_bus_yatm_network, -- needed for energy

  refresh_infotext = energy_bus_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_energy_bus_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_energy_bus_front.on.png"
    },
  },
  idle = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_energy_bus_front.idle.png"
    },
  }
})
