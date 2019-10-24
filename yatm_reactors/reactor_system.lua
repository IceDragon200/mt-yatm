local ReactorSystem = yatm_core.Class:extends("ReactorSystem")
local ic = ReactorSystem.instance_class

function ic:initialize()
  ic._super.initialize(self)
end

local function update_control_rod(node_entry, context)
  local node = minetest.get_node(node_entry.pos)
  local nodedef = minetest.registered_nodes[node.name]

  nodedef.reactor_device.update_control_rod(node_entry.pos, node, context, context.dtime)
  return true, context
end

function ic:update(cls, cluster, dtime)
  --print("Updating Cluster", network.id)
  cluster:reduce_nodes_of_groups({"controller"}, 0, function (node_entry, acc)
    local node = minetest.get_node(node_entry.pos)
    local nodedef = minetest.registered_nodes[node.name]

    if nodedef.reactor_device.state == "on" then
      context = {
        dtime = dtime,
        heat = 0,
        energy = 0,
      }
      cluster:reduce_nodes_of_groups({"control_rod"}, context, update_control_rod)
    end
    return false, acc
  end)
end

yatm_reactors.ReactorSystem = ReactorSystem
