--
-- YATM Brewery
--
local mod = foundation.new_module("yatm_brewery", "0.4.0")

mod:require("registries.lua")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")
mod:require("fluids.lua")

mod:require("tests.lua")
