--
-- YATM Data Console Monitor
--
yatm_data_console_monitor = rawget(_G, "yatm_data_console_monitor") or {}
yatm_data_console_monitor.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_console_monitor.modpath .. "/nodes.lua")

dofile(yatm_data_console_monitor.modpath .. "/migrations.lua")
