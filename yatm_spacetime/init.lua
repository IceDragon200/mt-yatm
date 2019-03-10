--[[
YATM Spacetime deals with instant transportion and other space and time manipulating nodes.
]]

yatm_spacetime = rawget(_G, "yatm_spacetime") or {}
yatm_spacetime.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_spacetime.modpath .. "/util.lua")
dofile(yatm_spacetime.modpath .. "/spacetime_network.lua")
dofile(yatm_spacetime.modpath .. "/nodes.lua")
dofile(yatm_spacetime.modpath .. "/items.lua")

dofile(yatm_spacetime.modpath .. "/tests.lua")

minetest.register_lbm({
  name = "yatm_spacetime:addressable_spacetime_device_lbm",
  nodenames = {
    "group:addressable_spacetime_device",
  },
  run_at_every_load = true,
  action = function (pos, node)
    local meta = minetest.get_meta(pos)
    local address = yatm_spacetime.get_address_in_meta(meta)
    if not yatm_core.is_blank(address) then
      yatm_spacetime.Network.register_device(pos, address)
    end
  end,
})
