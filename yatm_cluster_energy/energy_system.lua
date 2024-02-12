--
-- System module that runs under the energy cluster to resolve the energy generation and
-- distribution.
--

--- @namespace yatm_cluster_energy
local EnergyDevices = assert(yatm.energy.EnergyDevices)

local get_node_or_nil = assert(minetest.get_node_or_nil)

--- @class EnergySystem
local EnergySystem = foundation.com.Class:extends("EnergySystem")
do
  local ic = EnergySystem.instance_class

  --local LOG_GROUP = 'yatm.cluster.energy:energy_system'

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    self.m_time = 0
  end

  --- @spec #calc_energy_produced(Cluster, dtime: Float, trace: Trace): Integer
  function ic:calc_energy_produced(cluster, dtime, trace)
    local span
    local device_span

    if trace then
      span = trace:span_start("calc_energy_produced/3")
    end

    local pos
    local node
    local amount_produced

    local node_entry
    local list = cluster.m_group_nodes["energy_producer"]
    local nodes = cluster.m_nodes

    local energy_produced = 0

    if list then
      for node_id,_group_value in pairs(list) do
        node_entry = nodes[node_id]
        pos = node_entry.pos
        node = node_entry.node
        -- if span then
        --   device_span = span:span_start(node.name)
        -- end
        amount_produced = EnergyDevices.produce_energy(pos, node, dtime, device_span)
        -- if device_span then
        --   device_span:span_end()
        -- end
        node_entry.assigns.last_energy_produced = amount_produced
        if amount_produced then
          energy_produced = energy_produced + amount_produced
        end
      end
    end

    if span then
      span:span_end()
    end

    return energy_produced
  end

  --- @spec #calc_energy_stored(cluster: Cluster, dtime: Float, trace: Trace): Integer
  function ic:calc_energy_stored(cluster, dtime, trace)
    local span

    if trace then
      span = trace:span_start("calc_energy_stored/3")
    end

    local pos
    local node
    local device_stored

    local node_entry
    local list = cluster.m_group_nodes["energy_storage"]
    local nodes = cluster.m_nodes

    local energy_stored = 0

    if list then
      for node_id,_group_value in pairs(list) do
        node_entry = nodes[node_id]
        pos = node_entry.pos
        node = node_entry.node

        device_stored =
          EnergyDevices.get_usable_stored_energy(
            pos,
            node,
            dtime,
            span
          )

        if device_stored then
          energy_stored = energy_stored + device_stored
        end
      end
    end

    if span then
      span:span_end()
    end

    return energy_stored
  end

  -- @spec #run_consume_energy(
  --   energy_available: Integer,
  --   cluster: Cluster,
  --   dtime: Float,
  --   trace: Trace
  -- ): (energy_consumed: Integer, energy_available: Integer)
  function ic:run_consume_energy(energy_available, cluster, dtime, trace)
    local span

    if trace then
      span = trace:span_start("run_consume_energy/4")
    end

    local energy_consumed = 0

    if energy_available > 0 then
      --print(LOG_GROUP, "energy_available", energy_available, "=", energy_stored, " + ", energy_produced)

      -- Consumers are different from receivers, they use energy without any intention of storing it
      local amount_consumed
      local pos
      local node
      local node_entry

      local list = cluster.m_group_nodes["energy_consumer"]
      local nodes = cluster.m_nodes
      if list then
        for node_id,_group_value in pairs(list) do
          node_entry = nodes[node_id]
          pos = node_entry.pos
          -- node = get_node_or_nil(pos)
          node = node_entry.node

          amount_consumed = EnergyDevices.consume_energy(pos, node, energy_available, dtime, nil) --, span)
          if amount_consumed then
            energy_available = energy_available - amount_consumed
            energy_consumed = energy_consumed + amount_consumed
          end

          if energy_available <= 0 then
            break
          end
        end
      end
    end

    if span then
      span:span_end()
    end

    return energy_consumed, energy_available
  end

  --- @spec #run_use_stored_energy(
  ---   energy_available: Integer,
  ---   cluster: Cluster,
  ---   dtime: Float,
  ---   trace: Trace
  --- ): void
  function ic:run_use_stored_energy(energy_storage_consumed, cluster, dtime, trace)
    local span

    if trace then
      span = trace:span_start("run_use_stored_energy/4")
    end

    -- if we went over the produced, then the rest must be taken from the storage
    if energy_storage_consumed > 0 then
      local used
      local pos
      local node

      local node_entry
      local list = cluster.m_group_nodes["energy_storage"]
      local nodes = cluster.m_nodes

      if list then
        for node_id,_group_value in pairs(list) do
          node_entry = nodes[node_id]
          pos = node_entry.pos
          node = node_entry.node

          if node then
            used = EnergyDevices.use_stored_energy(pos, node, energy_storage_consumed, dtime, span)
            if used then
              energy_storage_consumed = energy_storage_consumed - used
            end
          end

          -- only continue if the energy_storage_consumed is still greater than 0
          if energy_storage_consumed <= 0 then
            break
          end
        end
      end
    end

    if span then
      span:span_end()
    end
  end

  --- @spec #run_receive_energy(
  ---   energy_left: Integer,
  ---   cluster: Cluster,
  ---   dtime: Float,
  ---   trace: Trace
  --- ): void
  function ic:run_receive_energy(energy_left, cluster, dtime, trace)
    local span

    if trace then
      span = trace:span_start("run_receive_energy/4")
    end

    if energy_left > 0 then
      local pos
      local node

      local node_entry
      local list = cluster.m_group_nodes["energy_receiver"]
      local nodes = cluster.m_nodes

      --print(LOG_GROUP, "energy_left", energy_left)
      -- Receivers are the lowest priority, they accept any left over energy from the production
      -- Incidentally, storage nodes tend to be also receivers
      local energy_received

      if list then
        for node_id,_group_value in pairs(list) do
          node_entry = nodes[node_id]
          pos = node_entry.pos
          node = node_entry.node

          energy_received = EnergyDevices.receive_energy(pos, node, energy_left, dtime, span)
          if energy_received then
            energy_left = energy_left -  energy_received
          end

          if energy_left <= 0 then
            break
          end
        end
      end
    end

    if span then
      span:span_end()
    end
  end

  function ic:run_has_update(cluster, dtime, trace)
    local span
    local device_span
    if trace then
      span = trace:span_start("run_has_update/3")
    end

    local pos
    local node
    local node_entry
    local nodedef
    local list = cluster.m_group_nodes["has_update"]
    local nodes = cluster.m_nodes
    if list then
      for node_id,_group_value in pairs(list) do
        node_entry = nodes[node_id]
        pos = node_entry.pos
        -- node = get_node_or_nil(pos)
        node = node_entry.node

        if node then
          nodedef = minetest.registered_nodes[node.name]

          if nodedef.yatm_network and nodedef.yatm_network.update then
            -- if span then
            --   device_span = span:span_start(node.name)
            -- end
            nodedef.yatm_network.update(pos, node, dtime, device_span)
            -- if device_span then
            --   device_span:span_end()
            -- end
          else
            print("energy_system", "INVALID UPDATABLE DEVICE", pos.x, pos.y, pos.z, node.name)
          end
        end
      end
    end

    if span then
      span:span_end()
    end
  end

  --- @spec #update(Clusters, Cluster, dtime: Number, trace?: Trace): void
  function ic:update(cls, cluster, dtime, trace)
    self.m_time = self.m_time + dtime

    local sys_trace
    local step_trace

    if trace then
      sys_trace = trace:span_start("energy_system")
    end

    if sys_trace then
      step_trace = sys_trace:span_start(cluster.id)
    end
    --print(LOG_GROUP, "dtime=" .. dtime, "cluster_id=" .. cluster.id, "size=" .. cluster:size(), "updating energy")

    --print(cluster:inspect())

    -- Highest priority, produce energy
    -- It's up to the node how it wants to deal with the energy, whether it's buffered, or just burst
    local energy_produced = self:calc_energy_produced(cluster, dtime, step_trace)

    -- Second highest priority, how much energy is stored in the network right now
    -- This is combined with the produced to determine how much is available
    -- The node is allowed to lie about its contents, to cause energy trickle or gating
    local energy_stored = self:calc_energy_stored(cluster, dtime, step_trace)

    -- The total available energy is the stored + produced
    local total_energy_available = energy_stored + energy_produced

    -- energy currently available = total
    local energy_available = total_energy_available

    local energy_consumed

    energy_consumed, energy_available =
      self:run_consume_energy(energy_available, cluster, dtime, step_trace)

    --print(LOG_GROUP, "energy_consumed", energy_consumed)
    local energy_store_used = energy_consumed - energy_produced
    if energy_store_used > 0 then
      self:run_use_stored_energy(energy_store_used, cluster, dtime, step_trace)
    end

    -- how much extra energy is left, note the stored is subtracted from the available
    -- if it falls below 0 then there is no extra energy.
    if energy_available > 0 then
      local energy_left = energy_produced - energy_consumed
      if energy_left > 0 then
        self:run_receive_energy(energy_left, cluster, dtime, step_trace)
      end
    end

    self:run_has_update(cluster, dtime, step_trace)

    if step_trace then
      step_trace:span_end()
    end

    if sys_trace then
      sys_trace:span_end()
    end
  end
end

yatm_cluster_energy.EnergySystem = EnergySystem
