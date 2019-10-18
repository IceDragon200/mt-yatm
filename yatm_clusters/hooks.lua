minetest.register_chatcommand("yatm.networks", {
  params = "<command> <params>",
  description = "Issue various commands to yatm networks",
  func = function (player_name, param)
    minetest.log("action", "yatm.networks " .. param)
    local params = string.split(param, ' ')
    if params[1] == "ls" then
      local network_ids = yatm_core.table_keys(Network.networks)
      minetest.chat_send_player(player_name, "Network IDs:" .. table.concat(network_ids, ', '))
    elseif params[1] == "describe" then
      -- describe <network-id>
      local network_id = params[2]
      network_id = string.trim(network_id)
      local network = Network.networks[network_id]
      if network then
        minetest.chat_send_player(player_name, network.node_name .. ' ' .. minetest.pos_to_string(network.pos) .. "\n" ..
                                               yatm_core.table_length(network.members) .. " Members")
      else
        minetest.chat_send_player(player_name, 'Network not found')
      end
    else
      minetest.chat_send_player(player_name, 'Invalid command')
    end
  end
})

minetest.register_lbm({
  name = "yatm_core:cluster_device_lbm",

  nodenames = {
    "group:yatm_cluster_device",
  },

  run_at_every_load = true,

  action = function (pos, node)
    yatm.clusters:schedule_event('cluster', 'on_load', pos, node)
  end,
})

minetest.register_on_shutdown(yatm_core.clusters:method("terminate"))
minetest.register_globalstep(yatm_core.clusters:method("update"))
