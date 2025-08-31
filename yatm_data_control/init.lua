--
-- YATM Data Control
--
local mod = foundation.new_module("yatm_data_control", "1.0.0")

mod:require("api.lua")

mod:require("items.lua")
mod:require("nodes.lua")

if foundation.is_module_present("yatm_codex") then
  mod:require("codex.lua")
end
