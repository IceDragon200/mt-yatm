--
-- YATM Security
--
local mod = foundation.new_module("yatm_security", "1.0.0")

mod:require("util.lua")
mod:require("formspec.lua")

mod:require("items.lua")
mod:require("nodes.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end
