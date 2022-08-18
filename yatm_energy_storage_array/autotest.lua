yatm_energy_storage_array.autotest_suite = yatm.autotest:new_suite("YATM Energy Storage Array")
yatm_energy_storage_array.autotest_suite:import_properties(yatm_machines.autotest_suite)

yatm_energy_storage_array:require("autotest/properties.lua")
yatm_energy_storage_array:require("autotest/models.lua")
