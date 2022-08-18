yatm_foundry.autotest_suite = yatm.autotest:new_suite("YATM Foundry")
yatm_foundry.autotest_suite:import_properties(yatm_machines.autotest_suite)

yatm_foundry:require("autotest/models.lua")
