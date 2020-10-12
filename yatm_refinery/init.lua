local mod = foundation.new_module("yatm_refinery", "1.0.0")

mod:require("vapour_registry.lua")
mod:require("distillation_registry.lua")

mod:require("api.lua")

mod:require("fluids.lua")
mod:require("nodes.lua")

mod:require("recipes.lua")
