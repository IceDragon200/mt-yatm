local migrations = {
  ["yatm_core:fluid_tank"] = "yatm_fluids:fluid_tank",

  ["yatm_core:fluid_tank_default_water"] = "yatm_fluids:fluid_tank_default_water",
  ["yatm_core:fluid_tank_default_lava"] = "yatm_fluids:fluid_tank_default_lava",
  ["yatm_core:fluid_tank_default_river_water"] = "yatm_fluids:fluid_tank_default_river_water",

  ["yatm_core:fluid_tank_yatm_core_oil"] = "yatm_fluids:fluid_tank_yatm_fluids_crude_oil",
  ["yatm_core:fluid_tank_yatm_core_heavy_oil"] = "yatm_fluids:fluid_tank_yatm_fluids_heavy_oil",
  ["yatm_core:fluid_tank_yatm_core_light_oil"] = "yatm_fluids:fluid_tank_yatm_fluids_light_oil",
  ["yatm_core:fluid_tank_yatm_core_garfielium"] = "yatm_fluids:fluid_tank_yatm_fluids_garfielium",
  ["yatm_core:fluid_tank_yatm_core_steam"] = "yatm_fluids:fluid_tank_yatm_fluids_steam",

  ["yatm_core:oil_source"] = "yatm_fluids:crude_oil_source",
  ["yatm_core:oil_flowing"] = "yatm_fluids:crude_oil_flowing",

  ["yatm_core:garfielium_source"] = "yatm_fluids:garfielium_source",
  ["yatm_core:garfielium_flowing"] = "yatm_fluids:garfielium_flowing",

  ["yatm_core:heavy_oil_source"] = "yatm_fluids:heavy_oil_source",
  ["yatm_core:heavy_oil_flowing"] = "yatm_fluids:heavy_oil_flowing",

  ["yatm_core:light_oil_source"] = "yatm_fluids:light_oil_source",
  ["yatm_core:light_oil_flowing"] = "yatm_fluids:light_oil_flowing",

  ["yatm_core:steam_oil_source"] = "yatm_fluids:steam_oil_source",
  ["yatm_core:steam_oil_flowing"] = "yatm_fluids:steam_oil_flowing",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_fluids:migrate_" .. string.gsub(from, ":", "_"),
    nodenames = {
      from,
    },
    run_at_every_load = true,
    action = function (pos, node)
      node.name = to
      minetest.swap_node(pos, node)
    end
  })
end
