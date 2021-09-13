local migrations = {
  ["yatm_cluster_thermal:thermal_duct_off"] = "yatm_thermal_ducts:thermal_duct_off",
  ["yatm_cluster_thermal:thermal_duct_heating"] = "yatm_thermal_ducts:thermal_duct_heating",
  ["yatm_cluster_thermal:thermal_duct_cooling"] = "yatm_thermal_ducts:thermal_duct_cooling",
  --
  ["yatm_cluster_thermal:thermal_node_off"] = "yatm_thermal_ducts:thermal_node_off",
  ["yatm_cluster_thermal:thermal_node_heating"] = "yatm_thermal_ducts:thermal_node_heating",
  ["yatm_cluster_thermal:thermal_node_cooling"] = "yatm_thermal_ducts:thermal_node_cooling",
  ["yatm_cluster_thermal:thermal_node_radiating"] = "yatm_thermal_ducts:thermal_node_radiating",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_thermal_ducts:migrate_" .. string.gsub(from, ":", "_"),

    nodenames = {
      from,
    },
    run_at_every_load = false,

    action = function (pos, node)
      node.name = to
      minetest.swap_node(pos, node)
    end
  })
end
