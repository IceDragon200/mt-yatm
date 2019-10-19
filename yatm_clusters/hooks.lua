local table_keys = assert(yatm_core.table_keys)
local table_length = assert(yatm_core.table_length)

minetest.register_chatcommand("yatm.networks", {
  params = "<command> <params>",
  description = "Issue various commands to yatm networks",
  func = function (player_name, param)
    minetest.log("action", "yatm.networks " .. param)
    local params = string.split(param, ' ')
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
minetest.register_globalstep(yatm.clusters:method("update"))

yatm.clusters:register_node_event_handler('refresh_infotext', function (_cls, _counter, event, _clusters)
  local pos = event.pos
  local node = event.node

  local nodedef = minetest.registered_nodes[node.name]

  if nodedef then
    if nodedef.refresh_infotext then
      local tracei = yatm_core.trace.new(node.name .. " refresh_infotext/2")
      nodedef.refresh_infotext(pos, node)
      yatm_core.trace.span_end(tracei)
    end
  end
end)
