local ReactorSystem = yatm_core.Class:extends("ReactorSystem")
local ic = ReactorSystem.instance_class

function ic:initialize()
  ic._super.initialize(self)
end

function ic:update(cls, cluster, dtime)
  --print("Updating Cluster", network.id)
  cluster:reduce_nodes_of_groups({"controller"}, 0, function (node_entry, acc)
    local node = minetest.get_node(node_entry.pos)
    local nodedef = minetest.registered_nodes[node.name]

    if nodedef.reactor_device.state == "on" then
      cluster:reduce_nodes_of_groups({"control_rod"}, 0, function (node_entry, acc)
        --print(dump(pos), dump(node))
        return true, acc + 1
      end)
    end
    return false, acc
  end)
end

yatm_reactors.ReactorSystem = ReactorSystem
