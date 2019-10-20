--
-- YATM Core
--
yatm_core = rawget(_G, "yatm_core") or {}
yatm_core.modpath = minetest.get_modpath(minetest.get_current_modname())

-- This is yatm's shared namespace, use the apis from this instead of the module's name when possible
yatm = rawget(_G, "yatm") or {}

local insec = minetest.request_insecure_environment()
if insec then
  yatm.io = assert(insec.io, "no IO available on the insecure environment!")
  yatm.bit = insec.require("bit")
  yatm.ffi = insec.require("ffi")
end

-- Classes, yadda, yadda, OOP is evil, yeah I get it, just use OOP sparingly.
dofile(yatm_core.modpath .. "/class.lua")
-- Util
dofile(yatm_core.modpath .. "/util.lua")
-- Instrumentation
dofile(yatm_core.modpath .. "/instrumentation.lua")
-- Utility
dofile(yatm_core.modpath .. "/meta_schema.lua")
dofile(yatm_core.modpath .. "/changeset.lua")
dofile(yatm_core.modpath .. "/ui.lua")
dofile(yatm_core.modpath .. "/groups.lua")
-- Networks
dofile(yatm_core.modpath .. "/measurable.lua") -- similar to energy, but has a name field too
-- Nodes and Items
dofile(yatm_core.modpath .. "/nodes.lua")
dofile(yatm_core.modpath .. "/items.lua")
-- Recipes
dofile(yatm_core.modpath .. "/recipes.lua")

-- Test Utils
dofile(yatm_core.modpath .. "/fake_meta_ref.lua")
dofile(yatm_core.modpath .. "/luna.lua")

-- Formspec Handle system
dofile(yatm_core.modpath .. "/formspec_handles.lua")

-- API
dofile(yatm_core.modpath .. "/api.lua")
-- Post Load Hooks
dofile(yatm_core.modpath .. "/post_hooks.lua")

-- Tests
dofile(yatm_core.modpath .. "/tests.lua")

-- prevent insecure modules from leaking
yatm.io = nil
yatm.bit = nil
yatm.ffi = nil
