yatm_refinery = rawget(_G, "yatm_refinery") or {}
yatm_refinery.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_refinery.modpath .. "/vapour_registry.lua")
dofile(yatm_refinery.modpath .. "/distillation_registry.lua")

dofile(yatm_refinery.modpath .. "/api.lua")

dofile(yatm_refinery.modpath .. "/fluids.lua")
dofile(yatm_refinery.modpath .. "/nodes.lua")

dofile(yatm_refinery.modpath .. "/recipes.lua")
