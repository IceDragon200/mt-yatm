local crusher_yatm_network = {
  kind = "machine",
  group = {machine = 1},
  states = {
    conflict = "yatm_machines:crusher_error",
    error = "yatm_machines:crusher_error",
    off = "yatm_machines:crusher_off",
    on = "yatm_machines:crusher_on",
  }
}

yatm_machines.register_network_device("yatm_machines:crusher_off", {
  description = "Crusher",
  groups = {cracky = 1},
  tiles = {
    "yatm_crusher_top.off.png",
    "yatm_crusher_bottom.png",
    "yatm_crusher_side.off.png",
    "yatm_crusher_side.off.png^[transformFX",
    "yatm_crusher_back.png",
    "yatm_crusher_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = crusher_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:crusher_error", {
  description = "Crusher",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_crusher_top.error.png",
    "yatm_crusher_bottom.png",
    "yatm_crusher_side.error.png",
    "yatm_crusher_side.error.png^[transformFX",
    "yatm_crusher_back.png",
    "yatm_crusher_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = crusher_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:crusher_on", {
  description = "Crusher",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_crusher_top.on.png",
    "yatm_crusher_bottom.png",
    "yatm_crusher_side.on.png",
    "yatm_crusher_side.on.png^[transformFX",
    "yatm_crusher_back.png",
    --"yatm_crusher_front.off.png"
    {
      name = "yatm_crusher_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = crusher_yatm_network,
})
