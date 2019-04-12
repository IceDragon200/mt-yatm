local migrations = {
  ["yatm_machines:heater"] = "yatm_foundry:electric_heater_off",
  ["yatm_machines:heater_on"] = "yatm_foundry:electric_heater_on",
  ["yatm_machines:heater_error"] = "yatm_foundry:electric_heater_error",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_foundry:migrate_" .. string.gsub(from, ":", "_"),
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
