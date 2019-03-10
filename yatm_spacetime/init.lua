--[[
YATM Spacetime deals with instant transportion and other space and time manipulating nodes.
]]

yatm_spacetime = rawget(_G, "yatm_spacetime") or {}
yatm_spacetime.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_spacetime.modpath .. "/nodes.lua")
