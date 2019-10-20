yatm.clusters:register_node_event_handler(CLUSTER_GROUP, yatm.cluster.energy:method('handle_node_event'))
yatm.clusters:observe('terminate', 'yatm_cluster_energy:terminate', yatm.cluster.energy:method('terminate'))

yatm.cluster.energy:register_system("yatm_cluster_energy:energy_logic", yatm_cluster_energy.energy_system:method("update"))

minetest.register_lbm({
  name = "yatm_cluster_energy:cluster_device_lbm",

  nodenames = {
    "group:yatm_cluster_energy",
  },

  run_at_every_load = true,

  action = function (pos, node)
    yatm.cluster.energy:schedule_load_node(pos, node)
  end,
})
