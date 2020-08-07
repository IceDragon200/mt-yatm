--[[

  YATM Armoury

  Offers weapons, armor and other items geared towards fights

]]
local mod = foundation.new_module("yatm_armoury", "0.1.0")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("recipes.lua")
