--
-- YATM Data Fluid Sensor
--
yatm_data_fluid_sensor = rawget(_G, "yatm_data_fluid_sensor") or {}
yatm_data_fluid_sensor.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_fluid_sensor.modpath .. "/nodes.lua")
