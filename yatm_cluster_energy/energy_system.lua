--
-- System module that runs under the energy cluster to resolve the energy generation and
-- distribution.
--

-- @namespace yatm_cluster_energy
local EnergyDevices = assert(yatm.energy.EnergyDevices)

local get_node_or_nil = minetest.get_node_or_nil

-- @class EnergySystem
local EnergySystem = foundation.com.Class:extends("EnergySystem")
local ic = EnergySystem.instance_class

--local LOG_GROUP = 'yatm.cluster.energy:energy_system'

-- @spec #initialize(): void
function ic:initialize()
  ic._super.initialize(self)
end

-- @spec #calc_energy_produced(Cluster, dtime: Float, trace: Trace): Integer
function ic:calc_energy_produced(cluster, dtime, trace)
  local span

  if trace then
    span = trace:span_start("produce_energy")
  end

  local node
  local amount_produced

  local energy_produced =
    cluster:reduce_nodes_of_group("energy_producer", 0, function (node_entry, acc)
      node = get_node_or_nil(node_entry.pos)
      --print(LOG_GROUP, "produce energy", node_entry.pos.x, node_entry.pos.y, node_entry.pos.z, node.name)
      if node then
        amount_produced = EnergyDevices.produce_energy(node_entry.pos, node, dtime, span)
        if amount_produced then
          acc = acc + amount_produced
        end
      end
      return true, acc
    end)

  if span then
    span:span_end()
  end

  return energy_produced
end

-- @spec #calc_energy_stored(cluster: Cluster, dtime: Float, trace: Trace): Integer
function ic:calc_energy_stored(cluster, dtime, trace)
  local span

  if trace then
    span = trace:span_start("calc_energy_stored")
  end

  local node
  local amount_stored

  local energy_stored =
    cluster:reduce_nodes_of_group("energy_storage", 0, function (node_entry, accumulated_energy_stored)
      node = get_node_or_nil(node_entry.pos)
      if node then
        amount_stored = EnergyDevices.get_usable_stored_energy(node_entry.pos, node, dtime, span)

        if amount_stored then
          accumulated_energy_stored = accumulated_energy_stored + amount_stored
        end
      end
      return true, accumulated_energy_stored
    end)

  if span then
    span:span_end()
  end

  return energy_stored
end

-- @spec #calc_energy_stored(
--   energy_available: Integer,
--   cluster: Cluster,
--   dtime: Float,
--   trace: Trace
-- ): (energy_consumed: Integer, energy_available: Integer)
function ic:run_consume_energy(energy_available, cluster, dtime, trace)
  local span

  if trace then
    span = trace:span_start("consume_energy")
  end

  local energy_consumed = 0

  if energy_available > 0 then
    --print(LOG_GROUP, "energy_available", energy_available, "=", energy_stored, " + ", energy_produced)

    -- Consumers are different from receivers, they use energy without any intention of storing it
    local amount_consumed
    local node

    energy_consumed =
      cluster:reduce_nodes_of_group("energy_consumer", energy_consumed, function (node_entry, acc)
        node = get_node_or_nil(node_entry.pos)

        if node then
          amount_consumed = EnergyDevices.consume_energy(node_entry.pos, node, energy_available, dtime, span)
          if amount_consumed then
            energy_available = energy_available - amount_consumed
            acc = acc + amount_consumed
          end
        end

        -- can't continue if we have no energy available
        return energy_available > 0, acc
      end)
  end

  if span then
    span:span_end()
  end

  return energy_consumed, energy_available
end

-- @spec #run_use_stored_energy(
--   energy_available: Integer,
--   cluster: Cluster,
--   dtime: Float,
--   trace: Trace
-- ): void
function ic:run_use_stored_energy(energy_storage_consumed, cluster, dtime, trace)
  local span

  if trace then
    span = trace:span_start("use_stored_energy")
  end

  -- if we went over the produced, then the rest must be taken from the storage
  if energy_storage_consumed > 0 then
    local used
    local node

    cluster:reduce_nodes_of_group("energy_storage", 0, function (node_entry, acc)
      node = get_node_or_nil(node_entry.pos)

      if node then
        used = EnergyDevices.use_stored_energy(node_entry.pos, node, energy_storage_consumed, dtime, span)
        if used then
          energy_storage_consumed = energy_storage_consumed + used
        end
      end

      -- only continue if the energy_storage_consumed is still greater than 0
      return energy_storage_consumed > 0, acc + 1
    end)
  end

  if span then
    span:span_end()
  end
end

-- @spec #run_receive_energy(
--   energy_left: Integer,
--   cluster: Cluster,
--   dtime: Float,
--   trace: Trace
-- ): void
function ic:run_receive_energy(energy_left, cluster, dtime, trace)
  local span

  if trace then
    span = trace:span_start("receive_energy")
  end

  if energy_left > 0 then
    local node

    --print(LOG_GROUP, "energy_left", energy_left)
    -- Receivers are the lowest priority, they accept any left over energy from the production
    -- Incidentally, storage nodes tend to be also receivers
    local energy_received
    cluster:reduce_nodes_of_group("energy_receiver", 0, function (node_entry, acc)
      node = get_node_or_nil(node_entry.pos)
      if node then
        energy_received = EnergyDevices.receive_energy(node_entry.pos, node, energy_left, dtime, span)
        if energy_received then
          energy_left = energy_left -  energy_received
        end
      end
      return energy_left > 0, acc + 1
    end)
  end

  if span then
    span:span_end()
  end
end

function ic:run_has_update(cluster, dtime, trace)
  local span
  if trace then
    span = trace:span_start("has_update")
  end

  local pos
  local node
  local tc
  local nodedef

  cluster:reduce_nodes_of_group("has_update", 0, function (node_entry, acc)
    pos = node_entry.pos
    node = get_node_or_nil(pos)

    if node then
      nodedef = minetest.registered_nodes[node.name]

      if nodedef.yatm_network and nodedef.yatm_network.update then
        if span then
          tc = span:span_start(node.name)
        end
        nodedef.yatm_network.update(pos, node, dtime, tc)
        if tc then
          tc:span_end()
        end
      else
        print("energy_system", "INVALID UPDATABLE DEVICE", pos.x, pos.y, pos.z, node.name)
      end
    end

    return true, acc + 1
  end)

  if span then
    span:span_end()
  end
end

function ic:update(cls, cluster, dtime, trace)
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
  -- The node is allowed to lie about it's contents, to cause energy trickle or gating
  local energy_stored = self:calc_energy_stored(cluster, dtime, step_trace)

  local total_energy_available = energy_stored + energy_produced
  local energy_available = total_energy_available

  local energy_consumed

  energy_consumed, energy_available = self:run_consume_energy(energy_available, cluster, dtime, step_trace)

  --print(LOG_GROUP, "energy_consumed", energy_consumed)
  self:run_use_stored_energy(energy_consumed - energy_produced, cluster, dtime, step_trace)

  -- how much extra energy is left, note the stored is subtracted from the available
  -- if it falls below 0 then there is no extra energy.
  local energy_left = energy_available - energy_consumed

  self:run_receive_energy(energy_left, cluster, dtime, step_trace)

  self:run_has_update(cluster, dtime, step_trace)

  if step_trace then
    step_trace:span_end()
  end

  if sys_trace then
    sys_trace:span_end()
  end
end

yatm_cluster_energy.EnergySystem = EnergySystem
