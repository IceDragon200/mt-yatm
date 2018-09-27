local auto_crafter_yatm_network = {
  kind = "machine",
  group = {machine = 1},
  states = {
    conflict = "yatm_machines:auto_crafter_error",
    error = "yatm_machines:auto_crafter_error",
    off = "yatm_machines:auto_crafter_off",
    on = "yatm_machines:auto_crafter_on",
  }
}

yatm_machines.register_network_device("yatm_machines:auto_crafter_off", {
  description = "Auto Crafter",
  groups = {cracky = 1},
  tiles = {
    "yatm_auto_crafter_top.off.png",
    "yatm_auto_crafter_bottom.png",
    "yatm_auto_crafter_side.png",
    "yatm_auto_crafter_side.png^[transformFX",
    "yatm_auto_crafter_back.png",
    "yatm_auto_crafter_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = auto_crafter_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:auto_crafter_error", {
  description = "Auto Crafter",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_auto_crafter_top.error.png",
    "yatm_auto_crafter_bottom.png",
    "yatm_auto_crafter_side.png",
    "yatm_auto_crafter_side.png^[transformFX",
    "yatm_auto_crafter_back.png",
    "yatm_auto_crafter_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = auto_crafter_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:auto_crafter_on", {
  description = "Auto Crafter",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    -- "yatm_auto_crafter_top.off.png",
    {
      name = "yatm_auto_crafter_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    "yatm_auto_crafter_bottom.png",
    "yatm_auto_crafter_side.png",
    "yatm_auto_crafter_side.png^[transformFX",
    "yatm_auto_crafter_back.png",
    -- "yatm_auto_crafter_front.off.png"
    {
      name = "yatm_auto_crafter_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = auto_crafter_yatm_network,
})
