local CLUSTER_GROUP = 'yatm_reactor'

yatm.cluster.reactor = yatm_reactors.ReactorCluster:new(CLUSTER_GROUP)

yatm.clusters:register_node_event_handler(
  CLUSTER_GROUP,
  "yatm_reactors:handle_node_event",
  yatm.cluster.reactor:method('handle_node_event')
)
yatm.clusters:observe('terminate', 'yatm_cluster_reactor:terminate', yatm.cluster.reactor:method('terminate'))

yatm_reactors.reactor_system = yatm_reactors.ReactorSystem:new()
yatm.cluster.reactor:register_system("yatm_cluster_reactor:reactor_logic", yatm_reactors.reactor_system:method("update"))

yatm.cluster_tool.register_cluster_tool_render(CLUSTER_GROUP, yatm.cluster.reactor:method("cluster_tool_render"))

minetest.register_lbm({
  name = "yatm_reactors:cluster_device_lbm",

  nodenames = {
    "group:yatm_cluster_reactor",
  },

  run_at_every_load = true,

  action = function (pos, node)
    yatm.cluster.reactor:schedule_load_node(pos, node)
  end,
})
