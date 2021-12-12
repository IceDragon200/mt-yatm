--
-- YATM Data Logic
--
local mod = foundation.new_module("yatm_data_logic", "2.0.0")

mod:require("formspec.lua")
mod:require("common.lua")
mod:require("data_math.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("migrations.lua")

if foundation.com.Luna then
  mod:require("tests.lua")
end
