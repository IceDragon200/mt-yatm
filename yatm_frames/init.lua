--
-- YATM Frames
--
local mod = foundation.new_module("yatm_frames", "1.0.0")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end

mod:require("tests.lua")
