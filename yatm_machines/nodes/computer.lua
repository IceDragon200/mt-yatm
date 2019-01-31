local computer_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:computer_error",
    error = "yatm_machines:computer_error",
    off = "yatm_machines:computer_off",
    on = "yatm_machines:computer_on",
  },
  passive_energy_lost = 1
}

function computer_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    -- do an update
  end
end

yatm_machines.register_network_device("yatm_machines:computer_off", {
  description = "Boiler",
  groups = {cracky = 1},
  tiles = {
    "yatm_computer_top.off.png",
    "yatm_computer_bottom.png",
    "yatm_computer_side.off.png",
    "yatm_computer_side.off.png^[transformFX",
    "yatm_computer_back.png",
    "yatm_computer_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = computer_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:computer_error", {
  description = "Boiler",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = "yatm_machines:computer_off",
  tiles = {
    "yatm_computer_top.error.png",
    "yatm_computer_bottom.png",
    "yatm_computer_side.error.png",
    "yatm_computer_side.error.png^[transformFX",
    "yatm_computer_back.png",
    "yatm_computer_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = computer_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:computer_on", {
  description = "Boiler",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = "yatm_machines:computer_off",
  tiles = {
    "yatm_computer_top.on.png",
    "yatm_computer_bottom.png",
    "yatm_computer_side.on.png",
    "yatm_computer_side.on.png^[transformFX",
    "yatm_computer_back.png",
    {
      name = "yatm_computer_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    }
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = computer_yatm_network,
})
