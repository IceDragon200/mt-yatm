local auto_grinder_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:auto_grinder_error",
    error = "yatm_machines:auto_grinder_error",
    off = "yatm_machines:auto_grinder_off",
    on = "yatm_machines:auto_grinder_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    startup_threshold = 100,
    network_charge_bandwidth = 1000,
  },
}

function auto_grinder_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  return 0
end

function auto_grinder_on_construct(pos)
  yatm.devices.device_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("grinder_input", 1)
  inv:set_size("grinder_processing", 1)
  inv:set_size("grinder_output", 1)
end

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Auto Grinder",

  groups = groups,

  drop = auto_grinder_yatm_network.states.off,

  tiles = {
    "yatm_auto_grinder_top.off.png",
    "yatm_auto_grinder_bottom.png",
    "yatm_auto_grinder_side.off.png",
    "yatm_auto_grinder_side.off.png^[transformFX",
    "yatm_auto_grinder_back.off.png",
    "yatm_auto_grinder_front.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = auto_grinder_on_construct,

  yatm_network = auto_grinder_yatm_network,
}, {
  on = {
    tiles = {
      "yatm_auto_grinder_top.on.png",
      "yatm_auto_grinder_bottom.png",
      "yatm_auto_grinder_side.on.png",
      "yatm_auto_grinder_side.on.png^[transformFX",
      "yatm_auto_grinder_back.on.png",
      -- "yatm_auto_grinder_front.off.png"
      {
        name = "yatm_auto_grinder_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.25
        },
      },
    },
  },
  error = {
    tiles = {
      "yatm_auto_grinder_top.error.png",
      "yatm_auto_grinder_bottom.png",
      "yatm_auto_grinder_side.error.png",
      "yatm_auto_grinder_side.error.png^[transformFX",
      "yatm_auto_grinder_back.error.png",
      "yatm_auto_grinder_front.error.png",
    },
  },
})
