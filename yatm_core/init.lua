--
-- YATM Core
--
local mod = foundation.new_module("yatm_core", "2.0.0")

-- This is yatm's shared namespace, use the apis from this instead of the module's name when possible
yatm = mod
yatm.config = yatm.config or {}

mod:require("config.lua")
mod:require("errors.lua")

-- Classes, yadda, yadda, OOP is evil, yeah I get it, just use OOP sparingly.
yatm_core.Class = foundation.com.Class

-- Utility
mod:require("changeset.lua")
-- Networks
mod:require("measurable.lua") -- similar to energy, but has a name field too

-- Formspec Handle system
mod:require("formspec_handles.lua")

-- Sounds
mod:require("sounds.lua")
mod.node_sounds = assert(foundation.com.node_sounds)

-- API
mod:require("api.lua")

-- Nodes and Items
mod:require("nodes.lua")
mod:require("items.lua")
-- Recipes
mod:require("recipes.lua")

-- Post Load Hooks
mod:require("post_hooks.lua")

-- determine which interop base yatm should work with
if rawget(_G, "default") then
  -- minetest game's default mod
  mod:require("interop/default.lua")
elseif rawget(_G, "nokore") then
  -- nokore
  mod:require("interop/nokore.lua")
else
  -- no base
  mod:require("interop/baseless.lua")
end


-- Tests
mod:require("tests.lua")

-- prevent insecure modules from leaking
yatm.native_bit = nil
yatm.ffi = nil
