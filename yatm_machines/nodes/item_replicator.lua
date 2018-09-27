local item_replicator_yatm_network = {
  kind = "machine",
  groups = {machine = 1}
}

minetest.register_node("yatm_machines:item_replicator", {
  description = "Item Replicator",
  groups = {cracky = 1},
  tiles = {
    "yatm_item_replicator_top.off.png",
    "yatm_item_replicator_bottom.png",
    "yatm_item_replicator_side.off.png",
    "yatm_item_replicator_side.off.png^[transformFX",
    "yatm_item_replicator_back.off.png",
    "yatm_item_replicator_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = item_replicator_yatm_network,
})

minetest.register_node("yatm_machines:item_replicator_on", {
  description = "Item Replicator",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_item_replicator_top.on.png",
    "yatm_item_replicator_bottom.png",
    "yatm_item_replicator_side.on.png",
    "yatm_item_replicator_side.on.png^[transformFX",
    {
      name = "yatm_item_replicator_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    {
      name = "yatm_item_replicator_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = item_replicator_yatm_network,
})
