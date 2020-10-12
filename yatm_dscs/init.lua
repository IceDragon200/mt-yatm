--
-- YATM DSCS (Digital Storage Crafting System)
--
local mod = foundation.new_module("yatm_dscs", "0.2.0")

mod:require("crafting_system.lua")

mod:require("api.lua")
mod:require("hooks.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("migrations.lua")
