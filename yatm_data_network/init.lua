--
-- YATM Data Network
--
local mod = foundation.new_module("yatm_data_network", "1.0.0")

mod:require("data_network.lua")

mod:require("api.lua")

mod:require("nodes.lua")
