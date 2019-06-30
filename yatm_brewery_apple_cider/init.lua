yatm_brewery_apple_cider = rawget(_G, "yatm_brewery_apple_cider") or {}
yatm_brewery_apple_cider.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_brewery_apple_cider.modpath .. "/fluids.lua")
dofile(yatm_brewery_apple_cider.modpath .. "/recipes.lua")

