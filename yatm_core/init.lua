--
-- YATM Core
--
yatm_core = rawget(_G, "yatm_core") or {}
yatm_core.modpath = minetest.get_modpath(minetest.get_current_modname())

-- This is yatm's shared namespace, use the apis from this instead of the module's name when possible
yatm = rawget(_G, "yatm") or {}
yatm.config = yatm.config or {}

dofile(yatm_core.modpath .. "/config.lua")
dofile(yatm_core.modpath .. "/errors.lua")

local insec = minetest.request_insecure_environment()
if insec then
  yatm.bit = insec.require("bit")
  yatm.ffi = insec.require("ffi")
else
  yatm.warn("yatm_core requested an insecure environment but received nil, several modules will be disabled due to this.")
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
yatm.bit = nil
yatm.ffi = nil
