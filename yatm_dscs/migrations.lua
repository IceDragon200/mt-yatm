local migrations = {
  ["yatm_machines:assembler_on"] = "yatm_dscs:assembler_on",
  ["yatm_machines:assembler_off"] = "yatm_dscs:assembler_off",
  ["yatm_machines:assembler_error"] = "yatm_dscs:assembler_error",

  ["yatm_machines:compute_module_on"] = "yatm_dscs:compute_module_on",
  ["yatm_machines:compute_module_off"] = "yatm_dscs:compute_module_off",
  ["yatm_machines:compute_module_error"] = "yatm_dscs:compute_module_error",

  ["yatm_machines:drive_case_on"] = "yatm_dscs:drive_case_on",
  ["yatm_machines:drive_case_off"] = "yatm_dscs:drive_case_off",
  ["yatm_machines:drive_case_error"] = "yatm_dscs:drive_case_error",

  ["yatm_machines:inventory_controller_on"] = "yatm_dscs:inventory_controller_on",
  ["yatm_machines:inventory_controller_off"] = "yatm_dscs:inventory_controller_off",
  ["yatm_machines:inventory_controller_error"] = "yatm_dscs:inventory_controller_error",

  -- Flat Monitors
  ["yatm_machines:flat_monitor_console_on"] = "yatm_dscs:flat_monitor_console_on",
  ["yatm_machines:flat_monitor_console_off"] = "yatm_dscs:flat_monitor_console_off",
  ["yatm_machines:flat_monitor_console_error"] = "yatm_dscs:flat_monitor_console_error",

  ["yatm_machines:flat_monitor_crafting_on"] = "yatm_dscs:flat_monitor_crafting_on",
  ["yatm_machines:flat_monitor_crafting_off"] = "yatm_dscs:flat_monitor_crafting_off",
  ["yatm_machines:flat_monitor_crafting_error"] = "yatm_dscs:flat_monitor_crafting_error",

  ["yatm_machines:flat_monitor_ele_on"] = "yatm_dscs:flat_monitor_ele_on",
  ["yatm_machines:flat_monitor_ele_off"] = "yatm_dscs:flat_monitor_ele_off",
  ["yatm_machines:flat_monitor_ele_error"] = "yatm_dscs:flat_monitor_ele_error",

  ["yatm_machines:flat_monitor_inventory_on"] = "yatm_dscs:flat_monitor_inventory_on",
  ["yatm_machines:flat_monitor_inventory_off"] = "yatm_dscs:flat_monitor_inventory_off",
  ["yatm_machines:flat_monitor_inventory_error"] = "yatm_dscs:flat_monitor_inventory_error",

  -- Monitors
  ["yatm_machines:monitor_console_on"] = "yatm_dscs:monitor_console_on",
  ["yatm_machines:monitor_console_off"] = "yatm_dscs:monitor_console_off",
  ["yatm_machines:monitor_console_error"] = "yatm_dscs:monitor_console_error",

  ["yatm_machines:monitor_crafting_on"] = "yatm_dscs:monitor_crafting_on",
  ["yatm_machines:monitor_crafting_off"] = "yatm_dscs:monitor_crafting_off",
  ["yatm_machines:monitor_crafting_error"] = "yatm_dscs:monitor_crafting_error",

  ["yatm_machines:monitor_ele_on"] = "yatm_dscs:monitor_ele_on",
  ["yatm_machines:monitor_ele_off"] = "yatm_dscs:monitor_ele_off",
  ["yatm_machines:monitor_ele_error"] = "yatm_dscs:monitor_ele_error",

  ["yatm_machines:monitor_inventory_on"] = "yatm_dscs:monitor_inventory_on",
  ["yatm_machines:monitor_inventory_off"] = "yatm_dscs:monitor_inventory_off",
  ["yatm_machines:monitor_inventory_error"] = "yatm_dscs:monitor_inventory_error",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_dscs:migrate_" .. string.gsub(from, ":", "_"),
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
