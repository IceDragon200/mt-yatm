--
-- YATM Rails
--
local mod = foundation.new_module("yatm_rails", "0.0.1")

mod:require("api.lua")

mod:require("entities.lua")
mod:require("nodes.lua")
mod:require("items.lua")

mod:require("tests.lua")
