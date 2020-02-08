local migrations = {
  ["yatm_dscs:monitor_console_error"] = "yatm_data_console_monitor:monitor_console_error",
  --["yatm_dscs:monitor_console_idle"] = "yatm_data_console_monitor:monitor_console_idle",
  ["yatm_dscs:monitor_console_off"] = "yatm_data_console_monitor:monitor_console_off",
  ["yatm_dscs:monitor_console_on"] = "yatm_data_console_monitor:monitor_console_on",

  ["yatm_dscs:flat_monitor_console_error"] = "yatm_data_console_monitor:flat_monitor_console_error",
  --["yatm_dscs:flat_monitor_console_idle"] = "yatm_data_console_monitor:flat_monitor_console_idle",
  ["yatm_dscs:flat_monitor_console_off"] = "yatm_data_console_monitor:flat_monitor_console_off",
  ["yatm_dscs:flat_monitor_console_on"] = "yatm_data_console_monitor:flat_monitor_console_on",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_data_console_monitor:migrate_" .. string.gsub(from, ":", "_"),
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
