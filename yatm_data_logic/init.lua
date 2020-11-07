--
-- YATM Data Logic
--
local mod = foundation.new_module("yatm_data_logic", "2.0.0")

mod:require("formspec.lua")
mod:require("common.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("migrations.lua")

mod:require("tests.lua")
