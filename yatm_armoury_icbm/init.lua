--[[

  YATM Armoury ICBM

  Provides long range missiles

]]
yatm_armoury_icbm = rawget(_G, "yatm_armoury_icbm") or {}
yatm_armoury_icbm.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_armoury_icbm.modpath .. "/api.lua")

dofile(yatm_armoury_icbm.modpath .. "/nodes.lua")
dofile(yatm_armoury_icbm.modpath .. "/items.lua")
dofile(yatm_armoury_icbm.modpath .. "/entities.lua")

dofile(yatm_armoury_icbm.modpath .. "/recipes.lua")
