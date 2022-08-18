local mod = yatm_autotest

mod:require("autotest.lua")

local autotest = yatm_autotest.Autotest:new()

minetest.register_on_shutdown(function ()
  autotest:on_shutdown()
end)

nokore_proxy.register_globalstep("yatm_autotest.update/1", function (dtime)
  autotest:update(dtime)
end)

-- minetest.register_chatcommand("yatm.autotest", {
--   params = "<state>",
--   description = "Activate yatm autotest framework",
--   func = function (player_name, param)
--     print(param)
--     autotest.active = param == "on"
--     print("Autotest.active", autotest.active)
--   end
-- })

yatm.autotest = autotest

-- Tests
-- dofile(yatm_autotest.modpath .. "/tests.lua")
