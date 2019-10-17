--[[
YATM Spacetime deals with instant transportion and other space and time manipulating nodes.
]]

yatm_spacetime = rawget(_G, "yatm_spacetime") or {}
yatm_spacetime.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_spacetime.modpath .. "/util.lua")
dofile(yatm_spacetime.modpath .. "/spacetime_meta.lua")
dofile(yatm_spacetime.modpath .. "/spacetime_network.lua")
dofile(yatm_spacetime.modpath .. "/api.lua")

dofile(yatm_spacetime.modpath .. "/nodes.lua")
dofile(yatm_spacetime.modpath .. "/items.lua")

minetest.register_lbm({
  name = "yatm_spacetime:addressable_spacetime_device_lbm",
  nodenames = {
    "group:addressable_spacetime_device",
  },
  run_at_every_load = true,
  action = function (pos, node)
    yatm_spacetime.network:maybe_update_node(pos, node)
  end,
})


dofile(yatm_spacetime.modpath .. "/tests.lua")
