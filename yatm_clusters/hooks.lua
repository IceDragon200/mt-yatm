local Trace = assert(foundation.com.Trace)
local string_split = assert(foundation.com.string_split)
local table_keys = assert(foundation.com.table_keys)
local table_length = assert(foundation.com.table_length)
local is_table_empty = assert(foundation.com.is_table_empty)
local clusters = assert(yatm.clusters)
local Symbols = assert(foundation.com.Symbols)

-- Allows the cluster tool to lookup normal clusters
yatm.cluster_tool.register_cluster_tool_lookup('yatm_clusters/standard', function (pos, state)
  return clusters:reduce_node_clusters(pos, state, function (cluster, acc)
    if cluster.groups.cluster_symbol_id then
      local symbol = Symbols:maybe_id_to_symbol(cluster.groups.cluster_symbol_id)
      acc[symbol] = cluster
    end
    return true, acc
  end)
end)

minetest.register_chatcommand("yatm.networks", {
  params = "<command> <params>",
  description = "Issue various commands to yatm networks",
  func = function (player_name, param)
    minetest.log("action", "yatm.networks " .. param)
    local params = string_split(param, ' ')
    if params[1] == "ls" then
      local network_ids = table_keys(Network.networks)
      minetest.chat_send_player(player_name, "Network IDs:" .. table.concat(network_ids, ', '))
    elseif params[1] == "describe" then
      -- describe <network-id>
      local network_id = params[2]
      network_id = string.trim(network_id)
      local network = Network.networks[network_id]
      if network then
        minetest.chat_send_player(player_name, network.node_name .. ' ' .. minetest.pos_to_string(network.pos) .. "\n" ..
                                               table_length(network.members) .. " Members")
      else
        minetest.chat_send_player(player_name, 'Network not found')
      end
    else
      minetest.chat_send_player(player_name, 'Invalid command')
    end
  end
})

minetest.register_on_shutdown(yatm.clusters:method("terminate"))
nokore_proxy.register_globalstep("yatm_clusters.update/1", yatm.clusters:method("update"))

yatm.clusters:register_node_event_handler('refresh_infotext', function (_cls, _counter, event, _clusters)
  local pos = event.pos
  local node = minetest.get_node_or_nil(pos)

  if node then
    local nodedef = minetest.registered_nodes[node.name]

    if nodedef and nodedef.refresh_infotext then
      local trace = Trace:new(node.name .. " refresh_infotext/2")
      nodedef.refresh_infotext(pos, node)
      trace:span_end()
    end
  end
end)
