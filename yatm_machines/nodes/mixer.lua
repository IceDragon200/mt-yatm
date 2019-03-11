local mixer_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:mixer_error",
    error = "yatm_machines:mixer_error",
    off = "yatm_machines:mixer_off",
    on = "yatm_machines:mixer_on",
  },
}

function mixer_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm.devices.register_network_device("yatm_machines:mixer_off", {
  description = "Mixer",
  groups = {cracky = 1},
  tiles = {
    "yatm_mixer_top.off.png",
    "yatm_mixer_bottom.png",
    "yatm_mixer_side.off.png",
    "yatm_mixer_side.off.png^[transformFX",
    "yatm_mixer_back.png",
    "yatm_mixer_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = mixer_yatm_network,
})

yatm.devices.register_network_device("yatm_machines:mixer_error", {
  description = "Mixer",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_mixer_top.error.png",
    "yatm_mixer_bottom.png",
    "yatm_mixer_side.error.png",
    "yatm_mixer_side.error.png^[transformFX",
    "yatm_mixer_back.png",
    "yatm_mixer_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = mixer_yatm_network,
})

yatm.devices.register_network_device("yatm_machines:mixer_on", {
  description = "Mixer",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_mixer_top.on.png",
    "yatm_mixer_bottom.png",
    "yatm_mixer_side.on.png",
    "yatm_mixer_side.on.png^[transformFX",
    "yatm_mixer_back.png",
    {
      name = "yatm_mixer_front.on.png",
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
  yatm_network = mixer_yatm_network,
})
