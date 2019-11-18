yatm_energy_storage = rawget(_G, "yatm_energy_storage") or {}
yatm_energy_storage.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_energy_storage.modpath .. "/inventory_batteries.lua")

dofile(yatm_energy_storage.modpath .. "/api.lua")

dofile(yatm_energy_storage.modpath .. "/items.lua")
dofile(yatm_energy_storage.modpath .. "/nodes.lua")

dofile(yatm_energy_storage.modpath .. "/migrations.lua")
