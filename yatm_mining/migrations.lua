local migrations = {
  ["yatm_machines:surface_drill_error"] = "yatm_mining:surface_drill_error",
  ["yatm_machines:surface_drill_off"] = "yatm_mining:surface_drill_off",
  ["yatm_machines:surface_drill_on"] = "yatm_mining:surface_drill_on",

  ["yatm_machines:surface_drill_ext_error"] = "yatm_mining:surface_drill_ext_error",
  ["yatm_machines:surface_drill_ext_off"] = "yatm_mining:surface_drill_ext_off",
  ["yatm_machines:surface_drill_ext_on"] = "yatm_mining:surface_drill_ext_on",

  ["yatm_machines:surface_drill_bit"] = "yatm_mining:surface_drill_bit",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_mining:migrate_" .. string.gsub(from, ":", "_"),
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
