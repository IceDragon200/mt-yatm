--
-- YATM Mesecon Locks
--
yatm_mesecon_locks = rawget(_G, "yatm_mesecon_locks") or {}
yatm_mesecon_locks.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_mesecon_locks.modpath .. "/items.lua")
dofile(yatm_mesecon_locks.modpath .. "/nodes.lua")
