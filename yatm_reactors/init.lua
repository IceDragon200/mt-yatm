yatm_reactors = rawget(_G, "yatm_reactors") or {}
yatm_reactors.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_reactors.modpath .. "/nodes.lua")
