--
-- YATM Machines
--
--[[
Machine behaviour

passive_energy_lost :: integer = 10
  how much energy should be lost when the network consume_energy is called?

network_charge_bandwidth :: integer
  how much energy should be stored from the consume_energy network call?

energy_capacity :: integer = maximum energy capacity

work_energy_bandwidth :: integer
  how much energy is allowed per work step?

work_rate_energy_threshold :: integer
  how much energy is required to reach a 100% work rate

startup_energy_threshold :: integer
  if the device is offline, how much energy does it require to go online?
]]
local mod = foundation.new_module("yatm_machines", "2.0.0")

mod:require("registries.lua")

mod:require("api.lua")
mod:require("nodes.lua")

mod:require("recipes.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end
