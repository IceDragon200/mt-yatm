--
-- YATM Item Storage
--
local mod = foundation.new_module("yatm_item_storage", "2.2.0")

mod:require("item_interface.lua")
mod:require("item_device.lua")
mod:require("item_exchange.lua")

mod:require("api.lua")

mod:require("nodes.lua")
