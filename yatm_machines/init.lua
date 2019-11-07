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
yatm_machines = rawget(_G, "yatm_machines") or {}
yatm_machines.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_machines.modpath .. "/condensing_registry.lua")
dofile(yatm_machines.modpath .. "/freezing_registry.lua")
dofile(yatm_machines.modpath .. "/grinding_registry.lua")

dofile(yatm_machines.modpath .. "/api.lua")
dofile(yatm_machines.modpath .. "/nodes.lua")

dofile(yatm_machines.modpath .. "/recipes.lua")
