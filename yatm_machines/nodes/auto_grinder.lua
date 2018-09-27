local auto_grinder_yatm_network = {
  kind = "machine",
  group = {machine = 1},
  states = {
    conflict = "yatm_machines:auto_grinder_error",
    error = "yatm_machines:auto_grinder_error",
    off = "yatm_machines:auto_grinder_off",
    on = "yatm_machines:auto_grinder_on",
  }
}

yatm_machines.register_network_device("yatm_machines:auto_grinder_off", {
  description = "Auto Grinder",
  groups = {cracky = 1},
  tiles = {
    "yatm_auto_grinder_top.off.png",
    "yatm_auto_grinder_bottom.png",
    "yatm_auto_grinder_side.png",
    "yatm_auto_grinder_side.png^[transformFX",
    "yatm_auto_grinder_back.png",
    "yatm_auto_grinder_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = auto_grinder_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:auto_grinder_error", {
  description = "Auto Grinder",
  groups = {cracky = 1},
  tiles = {
    "yatm_auto_grinder_top.error.png",
    "yatm_auto_grinder_bottom.png",
    "yatm_auto_grinder_side.png",
    "yatm_auto_grinder_side.png^[transformFX",
    "yatm_auto_grinder_back.png",
    "yatm_auto_grinder_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = auto_grinder_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:auto_grinder_on", {
  description = "Auto Grinder",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_auto_grinder_top.on.png",
    "yatm_auto_grinder_bottom.png",
    "yatm_auto_grinder_side.png",
    "yatm_auto_grinder_side.png^[transformFX",
    "yatm_auto_grinder_back.png",
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
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = auto_grinder_yatm_network,
})
