local mod = foundation.new_module("yatm_cluster_energy", "1.0.0")

-- Node Utilities
mod:require("energy_devices.lua")
-- Networks
mod:require("energy.lua")

mod:require("formspec.lua")
mod:require("api.lua")

mod:require("energy_system.lua")
mod:require("energy_cluster.lua")
mod:require("hooks.lua")

if foundation.com.Luna then
  mod:require("tests.lua")
end
