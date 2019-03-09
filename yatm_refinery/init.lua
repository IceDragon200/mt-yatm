yatm_refinery = rawget(_G, "yatm_refinery") or {}
yatm_refinery.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_refinery.modpath .. "/nodes.lua")
