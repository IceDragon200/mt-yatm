--
-- The thermal system is a bit different, it works by forcing it's neighbours to match each other
-- Producers will emit a specific heat value, all attached nodes will then slowly move towards that value.
--
local Directions = assert(foundation.com.Directions)

local ThermalSystem = foundation.com.Class:extends("ThermalSystem")
do
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
    self:run_produce_heat(cls, cluster, dtime, group_trace)
    if group_trace then
      group_trace:span_end()
    end

    if cls_trace then
      group_trace = cls_trace:span_start("updatable")
    end
    self:run_updatable(cls, cluster, dtime, group_trace)
    if group_trace then
      group_trace:span_end()
    end
  end

  function ic:run_produce_heat(cls, cluster, dtime, trace)
    local pos
    local node
    local node_entry
    local nodedef
    local heat_produced
    local neighbour_pos
    local neighbour_node_entry
    local neighbour_node
    local neighbour_nodedef
    local ti

    local list = cluster.m_group_nodes["thermal_producer"]
    local nodes = cluster.m_nodes

    if list then
      for node_id,_group_value in pairs(list) do
        node_entry = nodes[node_id]
        pos = node_entry.pos
        node = node_entry.node
        nodedef = minetest.registered_nodes[node.name]

        if nodedef and nodedef.thermal_interface then
          heat_produced = nodedef.thermal_interface:get_heat(pos, node, dtime)

          --print("Updating Cluster", cluster.id, dtime, heat_produced)
          for dir, vec3 in pairs(Directions.DIR6_TO_VEC3) do
            neighbour_pos = vector.add(pos, vec3)
            neighbour_node_entry = cluster:get_node(neighbour_pos)
            if neighbour_node_entry then
              neighbour_node = neighbour_node_entry.node
              neighbour_nodedef = minetest.registered_nodes[neighbour_node.name]

              ti = neighbour_nodedef and neighbour_nodedef.thermal_interface
              if ti then
                if ti.update_heat then
                  ti:update_heat(
                    neighbour_pos,
                    neighbour_node,
                    heat_produced,
                    dtime
                  )
                end
              else
                -- TODO: this should be reported, and maybe the cluster invalidated
              end
            end
          end
        else
          -- TODO: this should be reported, and maybe the cluster invalidated
        end
      end
    end
  end

  function ic:run_updatable(cls, cluster, dtime, trace)
    local node_entry
    local pos
    local node
    local nodedef
    local ti

    local list = cluster.m_group_nodes["updatable"]
    local nodes = cluster.m_nodes

    if list then
      for node_id,_group_value in pairs(list) do
        node_entry = nodes[node_id]
        pos = node_entry.pos
        node = node_entry.node
        nodedef = minetest.registered_nodes[node.name]
        if nodedef then
          ti = nodedef.thermal_interface
          if ti then
            ti:update(node_entry.pos, node, dtime)
          end
        end
      end
    end
  end
end

yatm_cluster_thermal.ThermalSystem = ThermalSystem
