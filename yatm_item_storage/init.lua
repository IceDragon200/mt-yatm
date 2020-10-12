--[[
YATM Item Storage
]]
local mod = foundation.new_module("yatm_item_storage", "1.0.0")

mod:require("item_interface.lua")
mod:require("inventory_serializer.lua")
mod:require("item_device.lua")

mod:require("api.lua")

mod:require("nodes.lua")

mod:require("tests.lua")
