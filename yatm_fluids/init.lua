local mod = foundation.new_module("yatm_fluids", "1.0.0")

mod:require("fluid_registry.lua")
mod:require("utils.lua")
mod:require("fluid_stack.lua")
mod:require("fluid_meta.lua")
mod:require("fluid_interface.lua")
mod:require("fluid_tanks.lua")
mod:require("fluid_exchange.lua")
mod:require("fluid_inventory.lua")

mod:require("api.lua")
mod:require("hooks.lua")

mod:require("fluid_tank_functions.lua")

mod:require("fluids.lua")
mod:require("nodes.lua")
mod:require("items.lua")

mod:require("tests.lua")

mod:require("migrations.lua")
