local migrations = {
  ["yatm_machines:battery_bank_off"] = "yatm_energy_storage:battery_bank_off",
  ["yatm_machines:battery_bank_on"] = "yatm_energy_storage:battery_bank_on0",
  ["yatm_energy_storage:battery_bank_on"] = "yatm_energy_storage:battery_bank_on0",
  ["yatm_machines:battery_bank_error"] = "yatm_energy_storage:battery_bank_error0",
  ["yatm_energy_storage:battery_bank_error"] = "yatm_energy_storage:battery_bank_error0",

  ["yatm_machines:energy_cell_basic_creative"] = "yatm_energy_storage:energy_cell_basic_creative",
  ["yatm_machines:energy_cell_normal_creative"] = "yatm_energy_storage:energy_cell_normal_creative",
  ["yatm_machines:energy_cell_dense_creative"] = "yatm_energy_storage:energy_cell_dense_creative",
}

for i = 0,7 do
  migrations["yatm_machines:energy_cell_basic_" .. i] = "yatm_energy_storage:energy_cell_basic_" .. i
  migrations["yatm_machines:energy_cell_normal_" .. i] = "yatm_energy_storage:energy_cell_normal_" .. i
  migrations["yatm_machines:energy_cell_dense_" .. i] = "yatm_energy_storage:energy_cell_dense_" .. i
end

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_energy_storage:migrate_" .. string.gsub(from, ":", "_"),
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
