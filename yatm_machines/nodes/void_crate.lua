local void_crate_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:void_crate_error",
    error = "yatm_machines:void_crate_error",
    off = "yatm_machines:void_crate_off",
    on = "yatm_machines:void_crate_on",
  }
}

function void_crate_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm_machines.register_network_device(void_crate_yatm_network.states.off, {
  description = "Void Crate",
  groups = {cracky = 1},
  drop = void_crate_yatm_network.states.off,
  tiles = {
    "yatm_void_crate_top.off.png",
    "yatm_void_crate_bottom.png",
    "yatm_void_crate_side.off.png",
    "yatm_void_crate_side.off.png^[transformFX",
    "yatm_void_crate_back.off.png",
    "yatm_void_crate_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = void_crate_yatm_network,
})

yatm_machines.register_network_device(void_crate_yatm_network.states.error, {
  description = "Void Crate",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = void_crate_yatm_network.states.off,
  tiles = {
    "yatm_void_crate_top.error.png",
    "yatm_void_crate_bottom.png",
    "yatm_void_crate_side.error.png",
    "yatm_void_crate_side.error.png^[transformFX",
    "yatm_void_crate_back.error.png",
    "yatm_void_crate_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = void_crate_yatm_network,
})

yatm_machines.register_network_device(void_crate_yatm_network.states.on, {
  description = "Void Crate",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = void_crate_yatm_network.states.off,
  tiles = {
    "yatm_void_crate_top.on.png",
    "yatm_void_crate_bottom.png",
    {
      name = "yatm_void_crate_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2
      },
    },
    {
      name = "yatm_void_crate_side.on.png^[transformFX",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2
      },
    },
    "yatm_void_crate_back.on.png",
    "yatm_void_crate_front.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = void_crate_yatm_network,
})
