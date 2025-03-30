--[[

  YATM Machines API

]]
local mod = foundation.new_module("yatm_machines_api", "0.1.0")

mod:require("registries.lua")

mod:require("behaviours.lua")
mod:require("api.lua")

mod:require("items.lua")
