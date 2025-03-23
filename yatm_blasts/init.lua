--[[

  YATM Blasts

  Provides logic for explosions

]]
local mod = foundation.new_module("yatm_blasts", "0.3.0")

mod:require("blasts_system.lua")

mod:require("api.lua")

if foundation.is_module_present("yatm_autotest") then
  mod:require("autotest.lua")
end

if foundation.is_module_present("foundation_unit_test") then
  mod:require("tests.lua")
end
