--
-- YATM Bees
--
local mod = foundation.new_module("yatm_bees", "1.1.0")

mod:require("registries.lua")

mod:require("api.lua")

mod:require("fluids.lua")
mod:require("nodes.lua")
mod:require("items.lua")

mod:require("recipes.lua")

mod:require("migrations.lua")
