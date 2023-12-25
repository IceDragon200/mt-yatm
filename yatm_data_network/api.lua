--- @namespace yatm_data_network

--- Primary instance of the yatm_data_network.DataNetwork
--- @const data_network: yatm_data_network.DataNetwork
yatm_data_network.data_network = yatm_data_network.DataNetwork:new{
  world = minetest,
  clusters = yatm.clusters
}

do
  -- the usual hooks
  -- initialization
  minetest.register_on_mods_loaded(yatm_data_network.data_network:method("init"))
  -- update
  nokore_proxy.register_globalstep(
    "yatm_data_network.update/1",
    yatm_data_network.data_network:method("update")
  )
  -- termination
  minetest.register_on_shutdown(yatm_data_network.data_network:method("terminate"))

  -- hook into the lbm to reload members of the cluster
  minetest.register_lbm({
    name = "yatm_data_network:data_network_reload_lbm",

    nodenames = {
      "group:yatm_data_device",
      "group:data_cable",
      "group:data_cable_bus",
    },

    run_at_every_load = true,
    action = function (pos, node)
      yatm.data_network:upsert_member(pos, node)
      local nodedef = minetest.registered_nodes[node.name]

      if nodedef then
        if nodedef.data_interface then
          nodedef.data_interface:on_load(pos, node)
        end
      end
    end
  })
end

--- @namespace yatm

--- @const DataNetwork = yatm_data_network.DataNetwork
yatm.DataNetwork = assert(yatm_data_network.DataNetwork)

--- @const data_network = yatm_data_network.data_network
yatm.data_network = assert(yatm_data_network.data_network)
