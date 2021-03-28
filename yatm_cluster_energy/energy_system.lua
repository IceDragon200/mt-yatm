--
-- System module that runs under the energy cluster to resolve the energy generation and
-- distribution.
--
local Trace = assert(foundation.com.Trace)
local EnergyDevices = assert(yatm.energy.EnergyDevices)

local EnergySystem = foundation.com.Class:extends("EnergySystem")
local ic = EnergySystem.instance_class

--local LOG_GROUP = 'yatm.cluster.energy:energy_system'

function ic:initialize()
  ic._super.initialize(self)
end

function ic:update(cls, cluster, dtime)
  local pot = Trace.new()
  local ot = Trace.span_start(pot, "cluster:" .. cluster.id)
  local span
  --print(LOG_GROUP, "dtime=" .. dtime, "cluster_id=" .. cluster.id, "size=" .. cluster:size(), "updating energy")

  --print(cluster:inspect())

  -- Highest priority, produce energy
  -- It's up to the node how it wants to deal with the energy, whether it's buffered, or just burst
  span = Trace.span_start(ot, "energy_producer")
  local energy_produced =
    cluster:reduce_nodes_of_groups("energy_producer", 0, function (node_entry, acc)
      local node = minetest.get_node_or_nil(node_entry.pos)
      --print(LOG_GROUP, "produce energy", node_entry.pos.x, node_entry.pos.y, node_entry.pos.z, node.name)
      if node then
        local amount_produced = EnergyDevices.produce_energy(node_entry.pos, node, dtime, span)
        if amount_produced then
          acc = acc + produced
        end
      end
      return true, acc
    end)
  Trace.span_end(span)

  -- Second highest priority, how much energy is stored in the network right now
  -- This is combined with the produced to determine how much is available
  -- The node is allowed to lie about it's contents, to cause energy trickle or gating
  span = Trace.span_start(ot, "energy_storage")
  local energy_stored =
    cluster:reduce_nodes_of_groups("energy_storage", 0, function (node_entry, accumulated_energy_stored)
      local node = minetest.get_node_or_nil(node_entry.pos)
      if node then
        local amount_stored = EnergyDevices.get_usable_stored_energy(node_entry.pos, node, dtime, span)

        if amount_stored then
          accumulated_energy_stored = accumulated_energy_stored + amount_stored
        end
      end
      return true, accumulated_energy_stored
    end)
  Trace.span_end(span)

  local span = Trace.span_start(ot, "energy_consumer")
  local total_energy_available = energy_stored + energy_produced
  local energy_available = total_energy_available

  --print(LOG_GROUP, "energy_available", energy_available, "=", energy_stored, " + ", energy_produced)

  -- Consumers are different from receivers, they use energy without any intention of storing it
  local energy_consumed =
    cluster:reduce_nodes_of_groups("energy_consumer", 0, function (node_entry, acc)
      local node = minetest.get_node_or_nil(node_entry.pos)

      if node then
        local amount_consumed = EnergyDevices.consume_energy(node_entry.pos, node, energy_available, dtime, span)
        if amount_consumed then
          energy_available = energy_available - amount_consumed
          acc = acc + amount_consumed
        end
      end

      -- can't continue if we have no energy available
      return energy_available > 0, acc
    end)
  Trace.span_end(span)

  --print(LOG_GROUP, "energy_consumed", energy_consumed)

  span = Trace.span_start(ot, "energy_storage")
  local energy_storage_consumed = energy_consumed - energy_produced
  -- if we went over the produced, then the rest must be taken from the storage
  if energy_storage_consumed > 0 then
    cluster:reduce_nodes_of_groups("energy_storage", 0, function (node_entry, acc)
      local node = minetest.get_node_or_nil(node_entry.pos)

      if node then
        local used = EnergyDevices.use_stored_energy(node_entry.pos, node, energy_storage_consumed, dtime, span)
        if used then
          energy_storage_consumed = energy_storage_consumed + used
        end
      end

      -- only continue if the energy_storage_consumed is still greater than 0
      return energy_storage_consumed > 0, acc + 1
    end)
  end
  Trace.span_end(span)

  -- how much extra energy is left, note the stored is subtracted from the available
  -- if it falls below 0 then there is no extra energy.
  span = Trace.span_start(ot, "energy_receiver")
  if energy_available > energy_stored then
    local energy_left = energy_available - energy_stored

    --print(LOG_GROUP, "energy_left", energy_left)
    -- Receivers are the lowest priority, they accept any left over energy from the production
    -- Incidentally, storage nodes tend to be also receivers
    cluster:reduce_nodes_of_groups("energy_receiver", 0, function (node_entry, acc)
      local node = minetest.get_node_or_nil(node_entry.pos)
      if node then
        local energy_received = EnergyDevices.receive_energy(node_entry.pos, node, energy_left, dtime, span)
        if energy_received then
          energy_left = energy_left -  energy_received
        end
      end
      return energy_left > 0, acc + 1
    end)
  end
  Trace.span_end(span)

  span = Trace.span_start(ot, "has_update")
  cluster:reduce_nodes_of_groups("has_update", 0, function (node_entry, acc)
    local pos = node_entry.pos
    local node = minetest.get_node_or_nil(pos)

    if node then
      local nodedef = minetest.registered_nodes[node.name]

      if nodedef.yatm_network and nodedef.yatm_network.update then
        local tc = Trace.span_start(span, node.name)
        nodedef.yatm_network.update(pos, node, dtime, tc)
        Trace.span_end(tc)
      else
        print("energy_system", "INVALID UPDATABLE DEVICE", pos.x, pos.y, pos.z, node.name)
      end
    end

    return true, acc + 1
  end)
  Trace.span_end(span)

  Trace.span_end(pot)
end

yatm_cluster_energy.EnergySystem = EnergySystem
