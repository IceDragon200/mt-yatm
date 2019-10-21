local trace = assert(yatm_core.trace)
local EnergyDevices = assert(yatm.energy.EnergyDevices)

local EnergySystem = yatm_core.Class:extends("EnergySystem")
local ic = EnergySystem.instance_class

local LOG_GROUP = 'yatm.cluster.energy:energy_system'

function ic:initialize()
  ic._super.initialize(self)
end

function ic:update(cls, cluster, dtime)
  local pot = trace.new()
  local ot = trace.span_start(pot, "cluster:" .. cluster.id)
  --print(LOG_GROUP, "dtime=" .. dtime, "cluster_id=" .. cluster.id, "size=" .. cluster:size(), "updating energy")

  --print(cluster:inspect())

  -- Highest priority, produce energy
  -- It's up to the node how it wants to deal with the energy, whether it's buffered, or just burst
  local span = trace.span_start(ot, "energy_producer")
  local energy_produced =
    cluster:reduce_nodes_of_groups("energy_producer", 0, function (node_entry, acc)
      --print(LOG_GROUP, "produce energy", node_entry.pos.x, node_entry.pos.y, node_entry.pos.z, node_entry.node.name)
      acc = acc + EnergyDevices.produce_energy(node_entry.pos, node_entry.node, dtime, span)
      return true, acc
    end)
  trace.span_end(span)

  -- Second highest priority, how much energy is stored in the network right now
  -- This is combined with the produced to determine how much is available
  -- The node is allowed to lie about it's contents, to cause energy trickle or gating
  local span = trace.span_start(ot, "energy_storage")
  local energy_stored =
    cluster:reduce_nodes_of_groups("energy_storage", 0, function (node_entry, accumulated_energy_stored)
      accumulated_energy_stored = accumulated_energy_stored +
                                  EnergyDevices.get_usable_stored_energy(node_entry.pos, node_entry.node, dtime, span)
      return true, accumulated_energy_stored
    end)
  trace.span_end(span)

  local span = trace.span_start(ot, "energy_consumer")
  local total_energy_available = energy_stored + energy_produced
  local energy_available = total_energy_available

  --print(LOG_GROUP, "energy_available", energy_available, "=", energy_stored, " + ", energy_produced)

  -- Consumers are different from receivers, they use energy without any intention of storing it
  local energy_consumed =
    cluster:reduce_nodes_of_groups("energy_consumer", 0, function (node_entry, acc)
      local consumed = EnergyDevices.consume_energy(node_entry.pos, node_entry.node, energy_available, dtime, span)
      if consumed then
        energy_available = energy_available - consumed
        acc = acc + consumed
      end
      -- can't continue if we have no energy available
      return energy_available > 0, acc
    end)
  trace.span_end(span)

  --print(LOG_GROUP, "energy_consumed", energy_consumed)

  local span = trace.span_start(ot, "energy_storage")
  local energy_storage_consumed = energy_consumed - energy_produced
  -- if we went over the produced, then the rest must be taken from the storage
  if energy_storage_consumed > 0 then
    cluster:reduce_nodes_of_groups("energy_storage", 0, function (node_entry, acc)
      local used = EnergyDevices.use_stored_energy(node_entry.pos, node_entry.node, energy_storage_consumed, dtime, span)
      if used then
        energy_storage_consumed = energy_storage_consumed + used
      end
      -- only continue if the energy_storage_consumed is still greater than 0
      return energy_storage_consumed > 0, acc + 1
    end)
  end
  trace.span_end(span)

  -- how much extra energy is left, note the stored is subtracted from the available
  -- if it falls below 0 then there is no extra energy.
  local span = trace.span_start(ot, "energy_receiver")
  if energy_available > energy_stored then
    local energy_left = energy_available - energy_stored

    --print(LOG_GROUP, "energy_left", energy_left)
    -- Receivers are the lowest priority, they accept any left over energy from the production
    -- Incidentally, storage nodes tend to be also receivers
    cluster:reduce_nodes_of_groups("energy_receiver", 0, function (node_entry, acc)
      local energy_received = EnergyDevices.receive_energy(node_entry.pos, node_entry.node, energy_left, dtime, span)
      if energy_received then
        energy_left = energy_left -  energy_received
      end
      return energy_left > 0, acc + 1
    end)
  end
  trace.span_end(span)

  local span = trace.span_start(ot, "has_update")
  cluster:reduce_nodes_of_groups("has_update", 0, function (node_entry, acc)
    local nodedef = minetest.registered_nodes[node_entry.node.name]
    if nodedef.yatm_network and nodedef.yatm_network.update then
      local tc = trace.span_start(span, node_entry.node.name)
      nodedef.yatm_network.update(node_entry.pos, node_entry.node, dtime, tc)
      trace.span_end(tc)
    else
      debug("network_device_update", "INVALID UPDATABLE DEVICE", pos.x, pos.y, pos.z, node.name)
    end
    return true, acc + 1
  end)
  trace.span_end(span)

  trace.span_end(pot)
end

yatm_cluster_energy.EnergySystem = EnergySystem
