--
-- YATM Core
--
local mod = foundation.new_module("yatm_core", "2.3.0")

local table_freeze = assert(foundation.com.table_freeze)

-- This is yatm's shared namespace, use the apis from this instead of the module's name when possible

--- @namespace yatm
yatm = rawget(_G, "yatm") or {}

--- @namespace yatm.config
yatm.config = yatm.config or {}

mod:require("config.lua")
mod:require("errors.lua")

-- Utility
mod:require("changeset.lua")
-- Networks
mod:require("measurable.lua") -- similar to energy, but has a name field too

-- Sounds
mod:require("sounds.lua")
yatm.node_sounds = assert(foundation.com.node_sounds)

-- API
mod:require("api.lua")

-- Nodes and Items
mod:require("nodes.lua")
mod:require("items.lua")
-- Recipes
mod:require("recipes.lua")

-- Post Load Hooks
mod:require("post_hooks.lua")

-- Interop
-- no base
mod:require("interop/baseless.lua")

-- determine which interop base yatm should work with
if rawget(_G, "default") then
  -- minetest game's default mod
  mod:require("interop/default.lua")
end

if rawget(_G, "nokore") then
  -- nokore
  mod:require("interop/nokore.lua")
end

if rawget(_G, "mcl_sounds") then
  -- mineclone2
  mod:require("interop/mineclone2.lua")
end
-- /Interop

-- Tests
if foundation.com.Luna then
  mod:require("tests.lua")
end

-- prevent insecure modules from leaking
yatm.native_bit = nil
yatm.ffi = nil
