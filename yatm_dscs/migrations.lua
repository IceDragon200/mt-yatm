local migrations = {
  ["yatm_machines:void_chest_error"] = "yatm_dscs:void_chest_error",
  ["yatm_machines:void_chest_idle"] = "yatm_dscs:void_chest_idle",
  ["yatm_machines:void_chest_off"] = "yatm_dscs:void_chest_off",
  ["yatm_machines:void_chest_on"] = "yatm_dscs:void_chest_on",

  ["yatm_machines:void_crate_error"] = "yatm_dscs:void_crate_error",
  ["yatm_machines:void_crate_idle"] = "yatm_dscs:void_crate_idle",
  ["yatm_machines:void_crate_off"] = "yatm_dscs:void_crate_off",
  ["yatm_machines:void_crate_on"] = "yatm_dscs:void_crate_on",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_dscs:migrate_" .. string.gsub(from, ":", "_"),
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
