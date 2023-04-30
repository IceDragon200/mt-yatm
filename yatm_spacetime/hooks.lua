local CLUSTER_GROUP = "yatm_gate"

yatm.cluster.gate = yatm_spacetime.GateCluster:new(CLUSTER_GROUP)

yatm.clusters:register_node_event_handler(
  CLUSTER_GROUP,
  "yatm_spacetime:handle_node_event",
  yatm.cluster.gate:method("handle_node_event")
)

yatm.clusters:observe(
  "terminate",
  "yatm_cluster_energy:terminate",
  yatm.cluster.gate:method("terminate")
)

yatm.cluster_tool.register_cluster_tool_render(
  CLUSTER_GROUP,
  yatm.cluster.gate:method("cluster_tool_render")
)

minetest.register_lbm({
  name = "yatm_spacetime:gate_lbm",

  nodenames = {
    "group:yatm_cluster_gate",
  },

  run_at_every_load = true,

  action = function (pos, node)
    yatm.cluster.gate:schedule_load_node(pos, node)
  end,
})

minetest.register_lbm({
  name = "yatm_spacetime:addressable_spacetime_device_lbm",

  nodenames = {
    "group:addressable_spacetime_device",
  },

  run_at_every_load = true,

  action = function (pos, node)
    yatm_spacetime.network:maybe_update_node(pos, node)
  end,
})
