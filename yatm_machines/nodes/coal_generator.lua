local coal_generator_yatm_network = {
  kind = "energy_producer",
  groups = {
    item_consumer = 1,
    energy_producer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:coal_generator_error",
    error = "yatm_machines:coal_generator_error",
    off = "yatm_machines:coal_generator_off",
    on = "yatm_machines:coal_generator_on",
  },
  energy = {
    capacity = 8000,
  }
}

function coal_generator_yatm_network.energy.produce_energy(pos, node, dtime, ot)
  return 0
end

function coal_generator_yatm_network.update(pos, node, ot)
end

local groups = {
  cracky = 1,
  yatm_network_host = 3,
  yatm_energy_device = 1,
  item_interface_in = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Coal Generator",
  groups = groups,

  drop = coal_generator_yatm_network.states.off,

  tiles = {
    "yatm_coal_generator_top.off.png",
    "yatm_coal_generator_bottom.png",
    "yatm_coal_generator_side.off.png",
    "yatm_coal_generator_side.off.png",
    "yatm_coal_generator_back.off.png",
    "yatm_coal_generator_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = coal_generator_yatm_network,
}, {
  on = {
    tiles = {
      --"yatm_coal_generator_top.on.png",
      {
        name = "yatm_coal_generator_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_coal_generator_bottom.png",
      "yatm_coal_generator_side.on.png",
      "yatm_coal_generator_side.on.png",
      "yatm_coal_generator_back.on.png",
      "yatm_coal_generator_front.on.png"
    },
  },
  error = {
    tiles = {
      "yatm_coal_generator_top.error.png",
      "yatm_coal_generator_bottom.png",
      "yatm_coal_generator_side.error.png",
      "yatm_coal_generator_side.error.png",
      "yatm_coal_generator_back.error.png",
      "yatm_coal_generator_front.error.png"
    },
  },
})
