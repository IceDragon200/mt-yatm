--
-- YATM Spacetime deals with instant transportion and other space and time manipulating nodes.
--
local mod = foundation.new_module("yatm_spacetime", "1.0.0")

mod:require("util.lua")
mod:require("spacetime_meta.lua")
mod:require("spacetime_network.lua")
mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

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

mod:require("tests.lua")
