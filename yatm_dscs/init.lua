--
-- YATM DSCS (Digital Storage Crafting System)
--
local mod = foundation.new_module("yatm_dscs", "0.3.0")

mod:require("api.lua")
mod:require("crafting_system.lua")
mod:require("formspec.lua")
mod:require("hooks.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("migrations.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end

if minetest.global_exists("yatm_autotest") then
  mod:require("autotest.lua")
end
