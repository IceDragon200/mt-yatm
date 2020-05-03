local electrolyser_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:electrolyser_error",
    error = "yatm_machines:electrolyser_error",
    off = "yatm_machines:electrolyser_off",
    on = "yatm_machines:electrolyser_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 10,
    startup_threshold = 200,
    network_charge_bandwidth = 100,
  }
}

function electrolyser_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
  return 0
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:electrolyser",

  description = "Electrolyser",
  groups = {cracky = 1},
  tiles = {
    "yatm_electrolyser_top.off.png",
    "yatm_electrolyser_bottom.png",
    "yatm_electrolyser_side.off.png",
    "yatm_electrolyser_side.off.png^[transformFX",
    "yatm_electrolyser_back.png",
    "yatm_electrolyser_front.off.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",
  yatm_network = electrolyser_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_electrolyser_top.error.png",
      "yatm_electrolyser_bottom.png",
      "yatm_electrolyser_side.error.png",
      "yatm_electrolyser_side.error.png^[transformFX",
      "yatm_electrolyser_back.png",
      "yatm_electrolyser_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_electrolyser_top.on.png",
      "yatm_electrolyser_bottom.png",
      "yatm_electrolyser_side.on.png",
      "yatm_electrolyser_side.on.png^[transformFX",
      "yatm_electrolyser_back.png",
      {
        name = "yatm_electrolyser_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
    },
  }
})
