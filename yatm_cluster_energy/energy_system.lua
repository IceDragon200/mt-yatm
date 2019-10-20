local trace = yatm_core.trace

local EnergySystem = yatm_core.Class:extends()
local ic = EnergySystem.instance_class

local LOG_GROUP = 'yatm.cluster.energy:energy_system'

function ic:initialize()
end

function ic:update(cls, cluster, dtime)
  local pot = trace.new()
  local ot = trace.span_start(pot, network.id)
  print(LOG_GROUP, counter, "updating energy cluster", network.id)

  -- Highest priority, produce energy
  -- It's up to the node how it wants to deal with the energy, whether it's buffered, or just burst
  local span = trace.span_start(ot, "energy_producer")
  local energy_produced = network:reduce_group_members("energy_producer", 0, function (pos, node, acc)
    print(LOG_GROUP, "produce energy", pos.x, pos.y, pos.z, node.name)
    acc = acc + EnergyDevices.produce_energy(pos, node, dtime, span)
    return true, acc
  end)
  trace.span_end(span)

  -- Second highest priority, how much energy is stored in the network right now
  -- This is combined with the produced to determine how much is available
  -- The node is allowed to lie about it's contents, to cause energy trickle or gating
  local span = trace.span_start(ot, "energy_storage")
  local energy_stored = network:reduce_group_members("energy_storage", 0, function (pos, node, acc)
    local nodedef = minetest.registered_nodes[node.name]
    acc = acc + EnergyDevices.get_usable_stored_energy(pos, node, dtime, span)
    return true, acc
  end)
  trace.span_end(span)

  local span = trace.span_start(ot, "energy_consumer")
  local total_energy_available = energy_stored + energy_produced
  local energy_available = total_energy_available

  print(LOG_GROUP, "energy_available", energy_available, "=", energy_stored, " + ", energy_produced)

  -- Consumers are different from receivers, they use energy without any intention of storing it
  local energy_consumed = network:reduce_group_members("energy_consumer", 0, function (pos, node, acc)
    local consumed = EnergyDevices.consume_energy(pos, node, energy_available, dtime, span)
    if consumed then
      energy_available = energy_available - consumed
      acc = acc + consumed
    end
    -- can't continue if we have no energy available
    return energy_available > 0, acc
  end)
  trace.span_end(span)

  print(LOG_GROUP, "energy_consumed", energy_consumed)

  local span = trace.span_start(ot, "energy_storage")
  local energy_storage_consumed = energy_consumed - energy_produced
  -- if we went over the produced, then the rest must be taken from the storage
  if energy_storage_consumed > 0 then
    network:reduce_group_members("energy_storage", 0, function (pos, node, acc)
      local used = EnergyDevices.use_stored_energy(pos, node, energy_storage_consumed, dtime, span)
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

    print(LOG_GROUP, "energy_left", energy_left)
    -- Receivers are the lowest priority, they accept any left over energy from the production
    -- Incidentally, storage nodes tend to be also receivers
    network:reduce_group_members("energy_receiver", 0, function (pos, node, acc)
      local energy_received = EnergyDevices.receive_energy(pos, node, energy_left, dtime, span)
      if energy_received then
        energy_left = energy_left -  energy_received
      end
      return energy_left > 0, acc + 1
    end)
  end
  trace.span_end(span)

  trace.span_end(pot)
end

yatm_energy_cluster.energy_system = EnergySystem:new()
