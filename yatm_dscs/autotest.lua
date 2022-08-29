yatm_dscs.autotest_suite = yatm.autotest:new_suite("YATM DSCS")
yatm_dscs.autotest_suite:import_properties(yatm_machines.autotest_suite)

yatm_dscs:require("autotest/properties.lua")

yatm_dscs:require("autotest/models.lua")
