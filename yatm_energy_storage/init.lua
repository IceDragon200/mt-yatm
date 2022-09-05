local mod = foundation.new_module("yatm_energy_storage", "1.0.0")

mod:require("inventory_batteries.lua")

mod:require("api.lua")

mod:require("items.lua")
mod:require("nodes.lua")

mod:require("migrations.lua")

if minetest.global_exists("yatm_autotest") then
  mod:require("autotest.lua")
end
