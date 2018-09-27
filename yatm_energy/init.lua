--
-- YATM Energy
--
--[[
Provides YATM an energy interface, for fluids, check YATM Fluids instead,
and for gases see YATM Gases
]]
yatm_energy = rawget(_G, "yatm_energy") or {}
yatm_energy.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_energy.modpath .. "/energy_network.lua")
dofile(yatm_energy.modpath .. "/energy_consumer.lua")
dofile(yatm_energy.modpath .. "/energy_producer.lua")
