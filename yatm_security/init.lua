--
-- YATM Security
--
local mod = foundation.new_module("yatm_security", "1.0.0")

mod:require("util.lua")
mod:require("formspec.lua")

mod:require("items.lua")
mod:require("nodes.lua")

if foundation.is_module_present("yatm_codex") then
  mod:require("codex.lua")
end

if minetest.global_exists("yatm_autotest") then
  mod:require("autotest.lua")
end
