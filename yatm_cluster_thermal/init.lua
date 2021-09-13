local mod = foundation.new_module("yatm_cluster_thermal", "1.0.0")

mod:require("thermal_system.lua")
mod:require("thermal_cluster.lua")
mod:require("api.lua")
mod:require("hooks.lua")

mod:require("tests.lua")
