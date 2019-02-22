local steam_turbine_yatm_network = {
  kind = "energy_producer",
  groups = {
    energy_producer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:steam_turbine_error",
    error = "yatm_machines:steam_turbine_error",
    off = "yatm_machines:steam_turbine_off",
    on = "yatm_machines:steam_turbine_on",
  }
}

function steam_turbine_yatm_network.update(pos, node, ot)
end

yatm_machines.register_network_device("yatm_machines:steam_turbine_off", {
  description = "Steam Turbine",
  groups = {cracky = 1},
  tiles = {
    "yatm_steam_turbine_top.off.png",
    "yatm_steam_turbine_bottom.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = steam_turbine_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:steam_turbine_error", {
  description = "Steam Turbine",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_steam_turbine_top.error.png",
    "yatm_steam_turbine_bottom.png",
    "yatm_steam_turbine_side.error.png",
    "yatm_steam_turbine_side.error.png",
    "yatm_steam_turbine_side.error.png",
    "yatm_steam_turbine_side.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = steam_turbine_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:steam_turbine_on", {
  description = "Steam Turbine",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    {
      name = "yatm_steam_turbine_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.4
      },
    },
    "yatm_steam_turbine_bottom.png",
    "yatm_steam_turbine_side.on.png",
    "yatm_steam_turbine_side.on.png",
    "yatm_steam_turbine_side.on.png",
    "yatm_steam_turbine_side.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = steam_turbine_yatm_network,
})
