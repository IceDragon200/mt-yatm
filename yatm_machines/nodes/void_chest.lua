local void_chest_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:void_chest_error",
    error = "yatm_machines:void_chest_error",
    off = "yatm_machines:void_chest_off",
    on = "yatm_machines:void_chest_on",
  }
}

function void_chest_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm_machines.register_network_device("yatm_machines:void_chest_off", {
  description = "Void Chest",
  groups = {cracky = 1},
  tiles = {
    "yatm_void_chest_top.off.png",
    "yatm_void_chest_bottom.png",
    "yatm_void_chest_side.off.png",
    "yatm_void_chest_side.off.png^[transformFX",
    "yatm_void_chest_back.off.png",
    "yatm_void_chest_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = void_chest_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:void_chest_error", {
  description = "Void Chest",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_void_chest_top.error.png",
    "yatm_void_chest_bottom.png",
    "yatm_void_chest_side.error.png",
    "yatm_void_chest_side.error.png^[transformFX",
    "yatm_void_chest_back.error.png",
    "yatm_void_chest_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = void_chest_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:void_chest_on", {
  description = "Void Chest",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_void_chest_top.on.png",
    "yatm_void_chest_bottom.png",
    {
      name = "yatm_void_chest_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2
      },
    },
    {
      name = "yatm_void_chest_side.on.png^[transformFX",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2
      },
    },
    "yatm_void_chest_back.on.png",
    "yatm_void_chest_front.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = void_chest_yatm_network,
})
