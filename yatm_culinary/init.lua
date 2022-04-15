--
-- YATM Culinary
--
local mod = foundation.new_module("yatm_culinary", "1.0.0")

mod:require("nodes.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end
