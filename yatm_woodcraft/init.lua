--
-- YATM Woodcraft
--
-- Provides the Sawmill and other wood processing blocks
--
local mod = foundation.new_module("yatm_woodcraft", "1.0.0")

mod:require("sawing_registry.lua")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("recipes.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end

if minetest.global_exists("yatm_autotest") then
  mod:require("autotest.lua")
end
