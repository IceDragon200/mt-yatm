local copy_node = assert(foundation.com.copy_node)
local is_table_empty = assert(foundation.com.is_table_empty)
local table_keys = assert(foundation.com.table_keys)
local table_length = assert(foundation.com.table_length)
local hash_node_position = assert(minetest.hash_node_position)

local DeviceCluster = yatm_clusters.SimpleCluster:extends("DeviceCluster")
local ic = DeviceCluster.instance_class

function ic:initialize(cluster_group)
  ic._super.initialize(self, {
    cluster_group = cluster_group,
    log_group = "yatm.cluster.device",
    node_group = "yatm_cluster_device"
  })
end

function ic:get_node_infotext(pos)
  local node_id = hash_node_position(pos)

  local cluster = self:get_node_cluster(pos)

  if cluster then
    local state_string = cluster.assigns.state or "unknown"
    local controller_id = cluster.assigns.controller_id
    if controller_id then
      if controller_id == node_id then
        state_string = state_string .. " - is host"
      end
    else
      state_string = state_string .. " - no available controller"
    end
    return "Device Cluster: " .. cluster.id .. " (" .. state_string .. ")"
  end

  return ""
end

function ic:get_node_groups(node)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef and nodedef.yatm_network then
    return nodedef.yatm_network.groups or {}
  end

  return {}
end

function ic:handle_node_event(cls, generation_id, event, node_clusters, trace)
  if event.event_name == "refresh_controller" then
    self:_handle_refresh_controller(cls, generation_id, event, node_clusters)

  elseif event.event_name == "transition_state" then
    self:_handle_transition_state(cls, generation_id, event, node_clusters)

  else
    ic._super.handle_node_event(self, cls, generation_id, event, node_clusters, trace)
  end
end

function ic:_handle_load_node(cls, generation_id, event, node_clusters)
  local cluster = ic._super._handle_load_node(self, cls, generation_id, event, node_clusters)
  if cluster then
    local node = minetest.get_node(event.pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.on_load then
        nodedef.yatm_network.on_load(event.pos, node)
      end
    end
  end
  return cluster
end

function ic:_handle_add_node(cls, generation_id, event, node_clusters)
  local cluster =
    ic._super._handle_add_node(
      self,
      cls,
      generation_id,
      event,
      node_clusters
    )

  cls:schedule_node_event(
    self.m_cluster_group,
    "refresh_controller",
    vector.copy(event.pos),
    copy_node(event.node),
    {
      cluster_id = cluster.id,
      generation_id = generation_id
    }
  )
  return cluster
end

function ic:on_cluster_branch_changed(cls, generation_id, event, cluster)
  cls:schedule_node_event(
    self.m_cluster_group,
    "refresh_controller",
    vector.copy(event.pos),
    copy_node(event.node),
    {
      cluster_id = cluster.id,
      generation_id = generation_id
    }
  )
end

function ic:transition_cluster_state(cls, cluster, generation_id, event, state)
  cls:schedule_node_event(
    self.m_cluster_group,
    "transition_state",
    vector.copy(event.pos),
    copy_node(event.node),
    {
      state = state,
      cluster_id = cluster.id,
      generation_id = generation_id
    }
  )
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

      local tiered_nodes =
        cluster:reduce_nodes_of_group("device_controller", {}, function (node_entry, acc)
          local tier = node_entry.groups["device_controller"]
          if not acc[tier] then
            acc[tier] = {}
          end
          acc[tier][node_entry.id] = node_entry
          return true, acc
        end)

      if is_table_empty(tiered_nodes) then
        -- no controllers or eligible leaders
        cluster.assigns.controller_id = nil
        cluster.assigns.controller_state = "down"

        self:transition_cluster_state(cls, cluster, generation_id, event, "down")
      else
        local tier1_nodes = tiered_nodes[1]

        if tier1_nodes then
          -- only 1 host should exist
          if table_length(tier1_nodes) > 1 then
            -- ho boi, we have a problem
            cluster.assigns.controller_id = nil
            cluster.assigns.controller_state = "conflict"

            self:transition_cluster_state(cls, cluster, generation_id, event, "conflict")
          else
            local node_id, _node_entry = next(tier1_nodes)

            cluster.assigns.controller_id = node_id
            cluster.assigns.controller_state = "up"

            self:transition_cluster_state(cls, cluster, generation_id, event, "up")
          end
        else
          -- just choose the first one, it's the leader for now.
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
          cluster.assigns.controller_state = "up"

          self:transition_cluster_state(cls, cluster, generation_id, event, "up")
        end
      end
    end
  else
    self:log("cluster requested a refresh_controller but it no longer exists cluster_id=" .. event.params.cluster_id)
  end
end

function ic:_handle_transition_state(cls, generation_id, event, node_clusters)
  self:log("transition_state", generation_id, 'cluster_id=' .. event.params.cluster_id, 'state=' .. event.params.state)
  local cluster = cls:get_cluster(event.params.cluster_id)
  if cluster then
    cluster.assigns.state = assert(event.params.state)
    cluster:reduce_nodes(0, function (node_entry, acc)
      -- fetch the _actual_ node, instead of the cluster's state
      local node = minetest.get_node_or_nil(node_entry.pos)
      if node then
        local nodedef = minetest.registered_nodes[node.name]
        if nodedef.transition_device_state then
          nodedef.transition_device_state(
            node_entry.pos,
            node,
            cluster.assigns.state,
            "cluster_device:transition_state"
          )
        end
      end
      return true, acc + 1
    end)
  else
    self:log("cluster requested a transition_state but it does not exist cluster_id=" .. event.params.cluster_id)
  end
end

local CLUSTER_GROUP = "yatm_device"

--
-- Called before a block is expired and removed from the clusters
function ic:on_pre_block_expired(block)
  yatm.clusters:reduce_clusters_of_group(CLUSTER_GROUP, 0, function (cluster, acc)
    cluster:reduce_nodes_in_block(block.id, 0, function (node_entry, acc2)
      local pos = node_entry.pos
      local node = node_entry.node -- this is the only time the old node entry has to be used

      local nodedef = minetest.registered_nodes[node.name]
      if nodedef and nodedef.yatm_network then
        if nodedef.yatm_network.on_unload then
          nodedef.yatm_network.on_unload(pos, node)
        end
      end
    end)
    return true, acc + 1
  end)
end

do
  yatm.cluster.DeviceCluster = DeviceCluster
  yatm.cluster.devices = DeviceCluster:new(CLUSTER_GROUP)

  yatm.clusters:register_node_event_handler(
    CLUSTER_GROUP,
    "yatm_cluster_devices:handle_node_event",
    yatm.cluster.devices:method('handle_node_event')
  )
  yatm.clusters:observe('pre_block_expired', 'yatm_cluster_devices:pre_block_expired', yatm.cluster.devices:method('on_pre_block_expired'))
  yatm.clusters:observe('terminate', 'yatm_cluster_devices:terminate', yatm.cluster.devices:method('terminate'))

  yatm.cluster_tool.register_cluster_tool_render(CLUSTER_GROUP, yatm.cluster.devices:method("cluster_tool_render"))

  minetest.register_lbm({
    name = "yatm_cluster_devices:cluster_device_lbm",

    nodenames = {
      "group:yatm_cluster_device",
    },

    run_at_every_load = true,

    action = function (pos, node)
      yatm.cluster.devices:schedule_load_node(pos, node)
    end,
  })
end
