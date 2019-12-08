local CLUSTER_GROUP = 'yatm_thermal'

yatm.cluster.thermal = yatm_cluster_thermal.ThermalCluster:new(CLUSTER_GROUP)

yatm.clusters:register_node_event_handler(CLUSTER_GROUP, yatm.cluster.thermal:method('handle_node_event'))
yatm.clusters:observe('terminate', 'yatm_cluster_thermal:terminate', yatm.cluster.thermal:method('terminate'))

yatm_cluster_thermal.thermal_system = yatm_cluster_thermal.ThermalSystem:new()
yatm.cluster.thermal:register_system("yatm_cluster_thermal:thermal_logic", yatm_cluster_thermal.thermal_system:method("update"))

minetest.register_lbm({
  name = "yatm_cluster_thermal:cluster_device_lbm",

  nodenames = {
    "group:yatm_cluster_thermal",
  },

  run_at_every_load = true,

  action = function (pos, node)
    yatm.cluster.thermal:schedule_load_node(pos, node)
  end,
})
