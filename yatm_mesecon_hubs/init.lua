--
-- YATM Mesecon Hubs
--
local mod = foundation.new_module("yatm_mesecon_hubs", "1.0.0")

mod:require("network_meta.lua")
mod:require("wireless_network.lua")
mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("tests.lua")
