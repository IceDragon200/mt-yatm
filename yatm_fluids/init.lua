yatm_fluids = rawget(_G, "yatm_fluids") or {}
yatm_fluids.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_fluids.modpath .. "/fluid_registry.lua")
dofile(yatm_fluids.modpath .. "/utils.lua")
dofile(yatm_fluids.modpath .. "/fluid_stack.lua")
dofile(yatm_fluids.modpath .. "/fluid_meta.lua")
dofile(yatm_fluids.modpath .. "/fluid_interface.lua")
dofile(yatm_fluids.modpath .. "/fluid_tanks.lua")
dofile(yatm_fluids.modpath .. "/fluid_exchange.lua")

dofile(yatm_fluids.modpath .. "/api.lua")
dofile(yatm_fluids.modpath .. "/hooks.lua")

dofile(yatm_fluids.modpath .. "/fluid_tank_functions.lua")

dofile(yatm_fluids.modpath .. "/fluids.lua")
dofile(yatm_fluids.modpath .. "/nodes.lua")
dofile(yatm_fluids.modpath .. "/items.lua")

dofile(yatm_fluids.modpath .. "/tests.lua")

dofile(yatm_fluids.modpath .. "/migrations.lua")
