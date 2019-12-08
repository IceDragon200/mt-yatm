--
-- The thermal system is a bit different, it works by forcing it's neighbours to match each other
-- Producers will emit a specific heat value, all attached nodes will then slowly move towards that value.
--
local trace = assert(yatm_core.trace)

local ThermalSystem = yatm_core.Class:extends("ThermalSystem")
local ic = ThermalSystem.instance_class

function ic:initialize()
  ic._super.initialize(self)
end

function ic:update(cls, cluster, dtime)
  local pot = trace.new()

  cluster:reduce_nodes_of_groups("thermal_producer", 0, function (node_entry, acc)
    local node = minetest.get_node_or_nil(node_entry.pos)
    local nodedef = minetest.registered_nodes[node.name]

    if not nodedef.thermal_interface then
      error("expected a thermal_interface node=" .. node.name)
    end

    local heat_produced = nodedef.thermal_interface:get_heat(node_entry.pos, node, dtime)

    --print("Updating Cluster", cluster.id, dtime, heat_produced)
    if heat_produced ~= 0 then
      for dir, vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
        local neighbour_pos = vector.add(node_entry.pos, vec3)
        local neighbour_node_entry = cluster:get_node(neighbour_pos)
        if neighbour_node_entry then
          local neighbour_node = minetest.get_node(neighbour_node_entry.pos)
          local neighbour_nodedef = minetest.registered_nodes[neighbour_node.name]

          if not neighbour_nodedef.thermal_interface then
            error("expected a thermal_interface node=" .. node.name)
          end

          if neighbour_nodedef.thermal_interface.update_heat then
            neighbour_nodedef.thermal_interface:update_heat(neighbour_pos, neighbour_node, heat_produced, dtime)
          end
        end
      end
    end

    return true, acc + 1
  end)

  cluster:reduce_nodes_of_groups("updatable", 0, function (node_entry, acc)
    local node = minetest.get_node(node_entry.pos)
    local nodedef = minetest.registered_nodes[node.name]

    nodedef.thermal_interface:update(node_entry.pos, node, dtime)

    return true, acc + 1
  end)

  trace.span_end(pot)
end

yatm_cluster_thermal.ThermalSystem = ThermalSystem
