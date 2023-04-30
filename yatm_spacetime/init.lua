--
-- YATM Spacetime deals with instant transportion and other space and time manipulating nodes.
--
local mod = foundation.new_module("yatm_spacetime", "1.1.0")

mod:require("util.lua")
mod:require("spacetime_meta.lua")
mod:require("spacetime_network.lua")
mod:require("gate_cluster.lua")
mod:require("hooks.lua")
mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

if foundation.com.Luna then
  mod:require("tests.lua")
end
