yatm_reactions = rawget(_G, "yatm_reactions") or {}
yatm_reactions.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_reactions.modpath .. "/reactions.lua")
