--[[

  YATM Blasts

  Provides logic for explosions

]]
local mod = foundation.new_module("yatm_blasts", "0.1.0")

mod.mod_storage = minetest.get_mod_storage()

mod:require("blasts_system.lua")

mod:require("api.lua")

-- so no one else gets a hold of it
mod.mod_storage = nil
