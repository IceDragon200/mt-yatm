--
-- YATM Brewery
--
local mod = foundation.new_module("yatm_brewery", "0.5.0")

mod:require("registries.lua")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")
mod:require("fluids.lua")

if foundation.com.Luna then
  mod:require("tests.lua")
end
