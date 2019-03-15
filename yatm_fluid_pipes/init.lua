--
-- YATM Fluid Pipes
--
yatm_fluid_pipes = rawget(_G, "yatm_fluid_pipes") or {}
yatm_fluid_pipes.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_fluid_pipes.modpath .. "/fluid_transport_network.lua")

dofile(yatm_fluid_pipes.modpath .. "/api.lua")

dofile(yatm_fluid_pipes.modpath .. "/nodes.lua")
