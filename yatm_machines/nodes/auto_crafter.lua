local auto_crafter_yatm_network = {
  basename = "yatm_machines:auto_crafter",
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:auto_crafter_error",
    error = "yatm_machines:auto_crafter_error",
    off = "yatm_machines:auto_crafter_off",
    on = "yatm_machines:auto_crafter_on",
  }
}

function auto_crafter_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_out = 1,
  item_interface_in = 1,
}

yatm.devices.register_network_device("yatm_machines:auto_crafter_off", {
  description = "Auto Crafter",
  groups = groups,
  drop = auto_crafter_yatm_network.states.off,
  tiles = {
    "yatm_auto_crafter_top.off.png",
    "yatm_auto_crafter_bottom.png",
    "yatm_auto_crafter_side.off.png",
    "yatm_auto_crafter_side.off.png^[transformFX",
    "yatm_auto_crafter_back.off.png",
    "yatm_auto_crafter_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(auto_crafter_yatm_network, {passive_energy_lost = 0}),
})

yatm.devices.register_network_device("yatm_machines:auto_crafter_error", {
  description = "Auto Crafter",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = auto_crafter_yatm_network.states.off,
  tiles = {
    "yatm_auto_crafter_top.error.png",
    "yatm_auto_crafter_bottom.png",
    "yatm_auto_crafter_side.error.png",
    "yatm_auto_crafter_side.error.png^[transformFX",
    "yatm_auto_crafter_back.error.png",
    "yatm_auto_crafter_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(auto_crafter_yatm_network, {passive_energy_lost = 0}),
})

yatm.devices.register_network_device("yatm_machines:auto_crafter_on", {
  description = "Auto Crafter",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = auto_crafter_yatm_network.states.off,
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
    "yatm_auto_crafter_side.on.png",
    "yatm_auto_crafter_side.on.png^[transformFX",
    "yatm_auto_crafter_back.on.png",
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
