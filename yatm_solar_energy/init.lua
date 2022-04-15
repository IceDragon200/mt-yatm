local mod = foundation.new_module("yatm_solar_energy", "0.2.0")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("recipes.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end
