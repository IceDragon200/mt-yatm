--[[

  YATM Blasts

  Provides logic for explosions

]]
yatm_blasts = rawget(_G, "yatm_blasts") or {}
yatm_blasts.modpath = minetest.get_modpath(minetest.get_current_modname())

yatm_blasts.mod_storage = minetest.get_mod_storage()

dofile(yatm_blasts.modpath .. "/blasts_system.lua")

dofile(yatm_blasts.modpath .. "/api.lua")

-- so no one else gets a hold of it
yatm_blasts.mod_storage = nil
