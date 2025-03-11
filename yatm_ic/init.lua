--[[

  YATM Integrated Circuits

]]
local mod = foundation.new_module("yatm_ic", "0.1.0")

mod:require("api.lua")

if foundation.com.Luna then
  mod:require("tests.lua")
end
