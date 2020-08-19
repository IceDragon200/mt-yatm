local data_network = assert(yatm.data_network)

local CLUSTER_GROUP = 'yatm_data'
-- Allows the cluster tool to lookup normal clusters
yatm.cluster_tool.register_cluster_tool_lookup(CLUSTER_GROUP, function (pos, state)
  local member = data_network:get_member_at_pos(pos)
  local network = data_network:get_network_at_pos(pos)

  local data = {}
  if member then
    data.member = member
    state[CLUSTER_GROUP] = data
  end

  if network then
    data.network = network
    state[CLUSTER_GROUP] = data
  end

  return state
end)

yatm.cluster_tool.register_cluster_tool_render(CLUSTER_GROUP, function (data, formspec, render_state)
  local registered_nodes_with_count = {}

  if data.network then
    for member_id, _is_present in pairs(data.network.members) do
      local member = data_network:get_member(member_id)

      registered_nodes_with_count[member.node.name] =
        (registered_nodes_with_count[member.node.name] or 0) + 1
    end
  end

  local cols = 4
  local colsize = render_state.w / cols
  local item_size = colsize * 0.6
  local label_size = colsize * 0.6
  local i = 0

  for node_name, count in pairs(registered_nodes_with_count) do
    local x = math.floor(i % cols) * colsize
    local y = math.floor(i / cols) * colsize

    local label_x = x + label_size
    local label_y = y + item_size / 2

    formspec =
      formspec ..
      "item_image[" .. x .. "," .. y .. ";" ..
                  item_size .. "," .. item_size .. ";" ..
                  node_name .. "]" ..
      "label[" .. label_x .. "," .. label_y.. ";" .. count .."]"

    i = i + 1
  end

  return formspec
end)
