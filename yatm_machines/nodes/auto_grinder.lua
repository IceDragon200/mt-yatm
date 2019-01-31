local auto_grinder_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:auto_grinder_error",
    error = "yatm_machines:auto_grinder_error",
    off = "yatm_machines:auto_grinder_off",
    on = "yatm_machines:auto_grinder_on",
  }
}

function auto_grinder_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm_machines.register_network_device("yatm_machines:auto_grinder_off", {
  description = "Auto Grinder",
  groups = {cracky = 1},
  drop = "yatm_machines:auto_grinder_off",
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
  yatm_network = auto_grinder_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:auto_grinder_error", {
  description = "Auto Grinder",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = "yatm_machines:auto_grinder_off",
  tiles = {
    "yatm_auto_grinder_top.error.png",
    "yatm_auto_grinder_bottom.png",
    "yatm_auto_grinder_side.error.png",
    "yatm_auto_grinder_side.error.png^[transformFX",
    "yatm_auto_grinder_back.error.png",
    "yatm_auto_grinder_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = auto_grinder_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:auto_grinder_on", {
  description = "Auto Grinder",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = "yatm_machines:auto_grinder_off",
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
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = auto_grinder_yatm_network,
})
