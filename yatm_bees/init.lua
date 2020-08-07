--
-- YATM Bees
--
local mod = foundation.new_module("yatm_bees", "1.0.0")

mod:require("api.lua")

mod:require("fluids.lua")
mod:require("nodes.lua")
mod:require("items.lua")

mod:require("migrations.lua")
