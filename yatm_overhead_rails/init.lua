--[[

  Overhead Rails

]]
yatm_overhead_rails = rawget(_G, "yatm_overhead_rails") or {}
yatm_overhead_rails.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_overhead_rails.modpath .. "/nodes.lua")
