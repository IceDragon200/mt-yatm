--
-- YATM Machines
--
local mod = foundation.new_module("yatm_machines", "3.0.0")

mod:require("nodes.lua")

mod:require("recipes.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end

if minetest.global_exists("yatm_autotest") then
  mod:require("autotest.lua")
end
