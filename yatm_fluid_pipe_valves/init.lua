--
-- YATM Fluid Pipe Valves
--
yatm_fluid_pipe_valves = rawget(_G, "yatm_fluid_pipe_valves") or {}
yatm_fluid_pipe_valves.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_fluid_pipe_valves.modpath .. "/nodes.lua")
