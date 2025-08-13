--[[

  YATM Recipe Components

]]
local mod = foundation.new_module("yatm_recipe_componens", "0.1.0")

yatm = rawget(_G, "yatm") or {}

-- Recipe Components
yatm.recipe_component = yatm.recipe_component or {}
mod:require("recipe_components/item_ingredient.lua")
mod:require("recipe_components/fluid_ingredient.lua") -- not used by workbench buuuuuut
mod:require("recipe_components/item_output.lua")
mod:require("recipe_components/fluid_output.lua")
mod:require("recipe_components/item_output_random.lua")
