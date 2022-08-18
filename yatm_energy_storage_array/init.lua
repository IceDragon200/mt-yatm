local mod = foundation.new_module("yatm_energy_storage_array", "1.0.0")

mod:require("nodes.lua")

if minetest.global_exists("yatm_autotest") then
  mod:require("autotest.lua")
end
