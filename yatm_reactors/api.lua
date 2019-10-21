local cluster_reactor = assert(yatm.cluster.reactor)

function yatm_reactors.default_on_construct(pos)
  local node = minetest.get_node(pos)
  cluster_reactor:schedule_add_node(pos, node)
end

function yatm_reactors.default_after_destruct(pos, old_node)
  cluster_reactor:schedule_remove_node(pos, old_node)
end

function yatm_reactors.register_reactor_node(name, nodedef)
  assert(name, "expected a name")
  assert(nodedef, "expected a nodedef")

  nodedef.groups = nodedef.groups or {}
  nodedef.groups['yatm_cluster_reactor'] = 1

  if nodedef.on_construct == nil then
    nodedef.on_construct = yatm_reactors.default_on_construct
  end

  if nodedef.after_destruct == nil then
    nodedef.after_destruct = yatm_reactors.default_after_destruct
  end

  return minetest.register_node(name, nodedef)
end

function yatm_reactors.register_stateful_reactor_node(base_node_def, overrides)
  overrides = overrides or {}
  assert(base_node_def, "expected a nodedef")
  assert(base_node_def.reactor_device, "expected a reactor_device")
  assert(base_node_def.reactor_device.states, "expected a reactor_device.states")
  assert(base_node_def.reactor_device.default_state, "expected a reactor_device.default_state")

  local seen = {}

  for state,name in pairs(base_node_def.reactor_device.states) do
    if not seen[name] then
      seen[name] = true

      local ov = overrides[state]
      if state == "conflict" and not ov then
        state = "error"
        ov = overrides[state]
      end
      ov = ov or {}
      local node_def = yatm_core.table_deep_merge(base_node_def, ov)
      local new_reactor_device = yatm_core.table_merge(node_def.reactor_device, {state = state})
      node_def.reactor_device = new_reactor_device

      if node_def.reactor_device.default_state ~= state then
        local groups = yatm_core.table_merge(node_def.groups, {not_in_creative_inventory = 1})
        node_def.groups = groups
      end

      yatm_reactors.register_reactor_node(name, node_def)
    end
  end
end
