local hub_nodebox = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, -0.25, 0.375},
  }
}

minetest.register_node("yatm_machines:hub_bus_off", {
  description = "Hub (bus) [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_hub_top.off.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
})

minetest.register_node("yatm_machines:hub_bus_on", {
  description = "Hub (bus) [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_hub_top.on.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
})

minetest.register_node("yatm_machines:hub_wireless_off", {
  description = "Hub (wireless) [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_hub_top.wireless.off.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
})

minetest.register_node("yatm_machines:hub_wireless_on", {
  description = "Hub (wireless) [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    {
      name = "yatm_hub_top.wireless.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
    "yatm_hub_bottom.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
})

minetest.register_node("yatm_machines:hub_elegens_off", {
  description = "Hub (ele) [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_hub_top.ele.off.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
})

minetest.register_node("yatm_machines:hub_elegens_on", {
  description = "Hub (ele) [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_hub_top.ele.on.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
})
