--
-- YATM DSCS (Digital Storage Crafting System)
--
yatm_dscs = rawget(_G, "yatm_dscs") or {}
yatm_dscs.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_dscs.modpath .. "/api.lua")
dofile(yatm_dscs.modpath .. "/nodes.lua")
dofile(yatm_dscs.modpath .. "/items.lua")

dofile(yatm_dscs.modpath .. "/migrations.lua")
