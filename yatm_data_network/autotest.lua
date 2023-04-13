local mod = assert(yatm_data_network)

yatm_data_network.autotest_suite = yatm.autotest:new_suite("YATM Data Network")

mod:require("autotest/models.lua")

mod:require("autotest/properties.lua")
