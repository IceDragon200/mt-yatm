--[[

  YATM Armoury C4

]]
local mod = foundation.new_module("yatm_armoury_c4", "0.1.0")

mod:require("nodes/c4.lua")
mod:require("nodes/tripwire.lua")
mod:require("items/c4_detonator.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end
