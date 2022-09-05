yatm_energy_storage.autotest_suite = yatm.autotest:new_suite("YATM Energy Storage")
yatm_energy_storage.autotest_suite:import_properties(yatm_machines.autotest_suite)

yatm_energy_storage:require("autotest/properties.lua")
yatm_energy_storage:require("autotest/models.lua")
