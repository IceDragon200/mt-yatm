local is_table_empty = yatm_core.is_table_empty
local table_keys = yatm_core.table_keys
local table_length = yatm_core.table_length
local DIR6_TO_VEC3 = yatm_core.DIR6_TO_VEC3

local ClusterDevices = yatm_core.Class:extends("ClusterDevices")
local ic = ClusterDevices.instance_class

function ic:initialize()
  --
end

function ic:terminate()
  print("cluster.devices", "terminated")
end

function ic:handle_node_event(cls, generation_id, event, node_clusters)
  if event.event_name == 'load_node' then
    -- treat loads like adding a node
    self:_handle_add_node(cls, generation_id, event, node_clusters)

  elseif event.event_name == 'add_node' then
    self:_handle_add_node(cls, generation_id, event, node_clusters)

  elseif event.event_name == 'remove_node' then
    self:_handle_remove_node(cls, generation_id, event, node_clusters)

  elseif event.event_name == 'refresh_controller' then
    self:_handle_refresh_controller(cls, generation_id, event, node_clusters)

  elseif event.event_name == 'transition_state' then
    self:_handle_transition_state(cls, generation_id, event, node_clusters)

  else
    print("cluster.devices", "unhandled event event_name=" .. event.event_name)
  end
end

function ic:_handle_add_node(cls, generation_id, event, node_clusters)
  -- pull up all neighbouring nodes from the given clusters
  local neighbours = {}
  if node_clusters and not is_table_empty(node_clusters) then
    for dir6, vec3 in pairs(DIR6_TO_VEC3) do
      local npos = vector.add(pos, vec3)

      for cluster_id, _ in pairs(node_clusters) do
        local cluster = cls:get_cluster(cluster_id)
        local node_entry = cluster:get_node(npos)

        if node_entry then
          neighbours[dir6] = {
            cluster_id = cluster_id,
            node_entry = node_entry
          }
          break
        end
      end
    end
  end

  -- Now you must be wondering, why would we need the neighbours?
  -- Easy, if they all belong to the same cluster:
  --   Then this node just needs to be added to it and the host controllers
  --   be refreshed,
  -- If there are multiple clusters:
  --   Then all the clusters get joined together, and host controllers checked again.
  -- If none:
  --   Then it just needs to create a cluster.
  local cluster
  if is_table_empty(neighbours) then
    -- need a new cluster for this node
    cluster = cls:create_cluster({ yatm_device = 1 })
  else
    -- attempt to join an existing cluster
    local cluster_ids = {}
    for _dir6, neighbour in pairs(neighbours) do
      cluster_ids[neighbour.cluster_id] = true
    end
    cluster_ids = table_keys(cluster_ids)

    if #cluster_ids == 1 then
      -- join the cluster
      local cluster_id = cluster_ids[1]
      cluster = cls:get_cluster(cluster_id)
    else
      -- merge the clusters and then join
      cluster = cls:merge_clusters(cluster_ids)
    end
  end

  cluster:add_node(event.pos, event.node, event.params.groups)

  -- trash the generation_id
  cluster.assigns.generation_id = nil

  cls:schedule_node_event('yatm_device', 'refresh_controller',
                           event.pos, event.node,
                           { cluster_id = cluster.id, generation_id = generation_id })
end

function ic:_handle_remove_node(cls, generation_id, event, node_clusters)
end

local function transition_cluster_state(cls, generation_id, event, state)
  cls:schedule_node_event('yatm_device', 'transition_state',
                          event.pos, event.node,
                          {
                            state = state,
                            cluster_id = cluster.id,
                            generation_id = generation_id
                          })
end

function ic:_handle_refresh_controller(cls, generation_id, event, node_clusters)
  -- normally called when the nodes have settled in
  local cluster = cls:get_cluster(event.params.cluster_id)
  if cluster then
    if cluster.assigns.generation_id == generation_id then
      -- we've already refreshed for this generation, skip this event
      return
    else
      -- it seems our generation is stale, refresh for real
      cluster.assigns.generation_id = generation_id

      local tiered_nodes = {}

      cluster.reduce_nodes_of_groups({'device_cluster_controller'}, tiered_nodes, function (node_entry, acc)
        local tier = node_entry.groups['device_cluster_controller']
        if not acc[tier] then
          acc[tier] = {}
        end
        acc[tier][node_entry.id] = node_entry
        return true, acc
      end)

      if is_table_empty(tiered_nodes) then
        -- just choose the first one, it's the leader for now.
        cluster.assigns.controller_id = nil

        transition_cluster_state(cls, generation_id, event, 'down')
      else
        local tier1_nodes = tiered_nodes[1]

        if tier1_nodes then
          -- only 1 host should exist
          if table_length(tier1_nodes) > 1 then
            -- ho boi, we have a problem
            cluster.assigns.controller_id = nil

            transition_cluster_state(cls, generation_id, event, 'error')
          else
            local node_id, _node_entry = next(tier1_nodes)

            cluster.assigns.controller_id = node_id

            transition_cluster_state(cls, generation_id, event, 'up')
          end
        else
          local tiers = table_keys(tiered_nodes)
          local highest_tier = 100
          for tier, _nodes in pairs(tiered_nodes) do
            if tier < highest_tier then
              highest_tier = tier
            end
          end

          local nodes = tiered_nodes[highest_tier]
          local node_id, _node_entry = next(nodes)

          cluster.assigns.controller_id = node_id

          transition_cluster_state(cls, generation_id, event, 'up')
        end
      end
    end
  else
    print("cluster.devices", "cluster requested a refresh_controller but it no longer exists cluster_id=" .. cluster_id)
  end
end

function ic:_handle_transition_state(cls, generation_id, event, node_clusters)
  local cluster = cls:get_cluster(event.params.cluster_id)
  if cluster then
    -- TODO: transition state is a massive call that will touch every node in the cluster.
  else
    print("cluster.devices", "cluster requested a transition_state but it no longer exists cluster_id=" .. cluster_id)
  end
end

yatm.cluster.devices = ClusterDevices:new()

yatm.clusters:register_node_event_handler('yatm_device', yatm.cluster.devices:method('handle_node_event'))
yatm.clusters:observe('terminate', yatm.cluster.devices:method('terminate'))
