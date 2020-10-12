--
-- Mining is focused on automated mining tools, such as the surface drill and quarry.
--
local mod = foundation.new_module("yatm_mining", "1.0.0")

mod:require("api.lua")

mod:require("nodes.lua")

mod:require("migrations.lua")

mod:require("tests.lua")
