yatm_refinery.autotest_suite = yatm.autotest:new_suite("YATM Refinery")
yatm_refinery.autotest_suite:import_properties(yatm_machines.autotest_suite)

yatm_refinery:require("autotest/models.lua")
