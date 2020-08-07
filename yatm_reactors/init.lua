local mod = foundation.new_module("yatm_reactors", "0.1.0")

mod:require("reactor_cluster.lua")
mod:require("reactor_system.lua")
mod:require("hooks.lua")
mod:require("api.lua")

mod:require("nodes.lua")

mod:require("migrations.lua")

--mod:require("tests.lua")
