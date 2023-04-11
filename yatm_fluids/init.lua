local mod = foundation.new_module("yatm_fluids", "2.3.0")

mod:require("fluid_registry.lua")
mod:require("utils.lua")
mod:require("fluid_stack.lua")
mod:require("fluid_meta.lua")
mod:require("fluid_interface.lua")
mod:require("fluid_tanks.lua")
mod:require("fluid_containers.lua")
mod:require("fluid_exchange.lua")
mod:require("fluid_inventory.lua")

mod:require("formspec.lua")
mod:require("api.lua")
mod:require("hooks.lua")

mod:require("fluid_tank_functions.lua")

mod:require("fluids.lua")
mod:require("nodes.lua")
mod:require("items.lua")

if foundation.com.Luna then
  mod:require("tests.lua")
end

if foundation.is_module_present("yatm_autotest") then
  mod:require("autotest.lua")
end

mod:require("migrations.lua")
