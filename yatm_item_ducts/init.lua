--
-- YATM Item Ducts
--
yatm_item_ducts = rawget(_G, "yatm_item_ducts") or {}
yatm_item_ducts.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_item_ducts.modpath .. "/item_transport_network.lua")

dofile(yatm_item_ducts.modpath .. "/api.lua")

dofile(yatm_item_ducts.modpath .. "/nodes.lua")
