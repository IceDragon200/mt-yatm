yatm_energy_storage_array = rawget(_G, "yatm_energy_storage_array") or {}
yatm_energy_storage_array.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_energy_storage_array.modpath .. "/nodes.lua")
