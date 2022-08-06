--
-- The thermal system is a bit different, it works by forcing it's neighbours to match each other
-- Producers will emit a specific heat value, all attached nodes will then slowly move towards that value.
--
local Directions = assert(foundation.com.Directions)

local ThermalSystem = foundation.com.Class:extends("ThermalSystem")
local ic = ThermalSystem.instance_class

function ic:initialize()
  ic._super.initialize(self)
end

function ic:update(cls, cluster, dtime, cls_trace)
  local node
  local nodedef
  local heat_produced
  local neighbour_pos
  local neighbour_node_entry
  local neighbour_node
  local neighbour_nodedef

  local group_trace

  if cls_trace then
    group_trace = cls_trace:span_start("thermal_producer")
  end
  cluster:reduce_nodes_of_group("thermal_producer", 0, function (node_entry, acc)
    node = minetest.get_node_or_nil(node_entry.pos)
    if node then
      nodedef = minetest.registered_nodes[node.name]

      if not nodedef.thermal_interface then
        error("expected a thermal_interface node=" .. node.name)
      end

      heat_produced = nodedef.thermal_interface:get_heat(node_entry.pos, node, dtime)

      --print("Updating Cluster", cluster.id, dtime, heat_produced)
      for dir, vec3 in pairs(Directions.DIR6_TO_VEC3) do
        neighbour_pos = vector.add(node_entry.pos, vec3)
        neighbour_node_entry = cluster:get_node(neighbour_pos)
        if neighbour_node_entry then
          neighbour_node = minetest.get_node(neighbour_node_entry.pos)
          neighbour_nodedef = minetest.registered_nodes[neighbour_node.name]

          if not neighbour_nodedef.thermal_interface then
            error("expected a thermal_interface node=" .. neighbour_node.name)
          end

          if neighbour_nodedef.thermal_interface.update_heat then
            neighbour_nodedef.thermal_interface:update_heat(neighbour_pos, neighbour_node, heat_produced, dtime)
          end
        end
      end
    end

    return true, acc + 1
  end)
  if group_trace then
    group_trace:span_end()
  end

  if cls_trace then
    group_trace = cls_trace:span_start("updatable")
  end
  cluster:reduce_nodes_of_group("updatable", 0, function (node_entry, acc)
    node = minetest.get_node(node_entry.pos)
    nodedef = minetest.registered_nodes[node.name]

    nodedef.thermal_interface:update(node_entry.pos, node, dtime)

    return true, acc + 1
  end)
  if group_trace then
    group_trace:span_end()
  end
end

yatm_cluster_thermal.ThermalSystem = ThermalSystem
