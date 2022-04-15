--
-- YATM Data Console Monitor
--
local mod = foundation.new_module("yatm_data_console_monitor", "0.2.0")

mod:require("nodes.lua")

mod:require("migrations.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end
