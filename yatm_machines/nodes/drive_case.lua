local drive_case_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:drive_case_error",
    error = "yatm_machines:drive_case_error",
    off = "yatm_machines:drive_case_off",
    on = "yatm_machines:drive_case_on",
  }
}

function drive_case_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm.devices.register_network_device(drive_case_yatm_network.states.off, {
  description = "Drive Case",
  groups = {cracky = 1},
  drop = drive_case_yatm_network.states.off,
  tiles = {
    "yatm_drive_case_top.off.png",
    "yatm_drive_case_bottom.png",
    "yatm_drive_case_side.off.png",
    "yatm_drive_case_side.off.png^[transformFX",
    "yatm_drive_case_back.off.png",
    "yatm_drive_case_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = drive_case_yatm_network,
})

yatm.devices.register_network_device(drive_case_yatm_network.states.error, {
  description = "Drive Case",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = drive_case_yatm_network.states.off,
  tiles = {
    "yatm_drive_case_top.error.png",
    "yatm_drive_case_bottom.png",
    "yatm_drive_case_side.error.png",
    "yatm_drive_case_side.error.png^[transformFX",
    "yatm_drive_case_back.error.png",
    "yatm_drive_case_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = drive_case_yatm_network,
})

yatm.devices.register_network_device(drive_case_yatm_network.states.on, {
  description = "Drive Case",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = drive_case_yatm_network.states.off,
  tiles = {
    "yatm_drive_case_top.on.png",
    "yatm_drive_case_bottom.png",
    "yatm_drive_case_side.on.png",
    "yatm_drive_case_side.on.png^[transformFX",
    "yatm_drive_case_back.on.png",
    "yatm_drive_case_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = drive_case_yatm_network,
})
