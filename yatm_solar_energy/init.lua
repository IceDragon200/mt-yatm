yatm_solar_energy = rawget(_G, "yatm_solar_energy") or {}
yatm_solar_energy.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_solar_energy.modpath .. "/api.lua")

dofile(yatm_solar_energy.modpath .. "/nodes.lua")

dofile(yatm_solar_energy.modpath .. "/recipes.lua")
