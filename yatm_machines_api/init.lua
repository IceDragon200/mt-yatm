--[[

  YATM Machines API

]]
local mod = foundation.new_module("yatm_machines_api", "0.1.0")

yatm.devices = yatm.devices or {}

mod:require("registries.lua")

mod:require("behaviours.lua")
mod:require("upgrades.lua")
mod:require("api.lua")

mod:require("items.lua")
mod:require("upgrades_impl.lua")
