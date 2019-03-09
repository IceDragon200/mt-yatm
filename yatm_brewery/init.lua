yatm_brewery = rawget(_G, "yatm_brewery") or {}
yatm_brewery.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_brewery.modpath .. "/nodes.lua")
