--
-- YATM Data Cables
--
local mod = foundation.new_module("yatm_data_cables", "1.0.0")

mod:require("nodes.lua")

if foundation.is_module_present("yatm_codex") then
  mod:require("codex.lua")
end
