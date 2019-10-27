--
-- YATM Frames
--
yatm_frames = rawget(_G, "yatm_frames") or {}
yatm_frames.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_frames.modpath .. "/api.lua")

dofile(yatm_frames.modpath .. "/nodes.lua")
dofile(yatm_frames.modpath .. "/items.lua")

dofile(yatm_frames.modpath .. "/tests.lua")
