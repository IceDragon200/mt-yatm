--[[
YATM Mesecon Buttons
]]
yatm_mesecon_buttons = rawget(_G, "yatm_mesecon_buttons") or {}
yatm_mesecon_buttons.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_mesecon_buttons.modpath .. "/nodes.lua")
