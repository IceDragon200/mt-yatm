local item_replicator_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    creative_replicator = 1,
  },
  states = {
    error = "yatm_machines:item_replicator_error",
    conflict = "yatm_machines:item_replicator_error",
    off = "yatm_machines:item_replicator_off",
    on = "yatm_machines:item_replicator_on",
  }
}

local groups = {
  cracky = 1,
  item_interface_out = 1,
}

yatm.devices.register_network_device(item_replicator_yatm_network.states.off, {
  description = "Item Replicator",
  groups = groups,
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

yatm.devices.register_network_device(item_replicator_yatm_network.states.error, {
  description = "Item Replicator",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  tiles = {
    "yatm_item_replicator_top.error.png",
    "yatm_item_replicator_bottom.png",
    "yatm_item_replicator_side.error.png",
    "yatm_item_replicator_side.error.png^[transformFX",
    "yatm_item_replicator_back.error.png",
    "yatm_item_replicator_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = item_replicator_yatm_network,
})

yatm.devices.register_network_device(item_replicator_yatm_network.states.on, {
  description = "Item Replicator",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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
