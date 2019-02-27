--
-- YATM Machines
--
--[[
Machine behaviour

passive_energy_lost :: integer = 10
  how much energy should be lost when the network consume_energy is called?

network_charge_bandwidth :: integer
  how much energy should be stored from the consume_energy network call?

energy_capacity :: integer = maximum energy capacity

work_energy_bandwidth :: integer
  how much energy is allowed per work step?

work_rate_energy_threshold :: integer
  how much energy is required to reach a 100% work rate

startup_energy_threshold :: integer
  if the device is offline, how much energy does it require to go online?
]]
yatm_machines = rawget(_G, "yatm_machines") or {}
yatm_machines.modpath = minetest.get_modpath(minetest.get_current_modname())

function yatm_machines.device_on_destruct(pos)
  return yatm_core.Network.device_on_destruct(pos)
end

function yatm_machines.device_after_destruct(pos, node)
  return yatm_core.Network.device_after_destruct(pos, node)
end

function yatm_machines.device_after_place_node(pos)
  return yatm_core.Network.device_after_place_node(pos)
end

function yatm_machines.default_on_device_changed(pos, node, origin_pos, origin_node)
  print("yatm_machines.default_on_device_changed/4", pos.x, pos.y, pos.z, node.name, "ORIGIN", origin_pos.x, origin_pos.y, origin_pos.z, origin_node.name)
  yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "device_changed"})
end

function yatm_machines.network_passive_consume_energy(pos, node, amount)
  local consumed = 0
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.yatm_network then
    local ym = nodedef.yatm_network
    local passive = ym.passive_energy_lost
    if passive > 0 then
      consumed = consumed + math.min(amount, passive)
    end
    local remaining = amount - consumed
    local charge_bandwidth = ym.network_charge_bandwidth
    if charge_bandwidth and charge_bandwidth > 0 and remaining > 0 then
      local capacity = ym.energy_capacity
      local meta = minetest.get_meta(pos)
      local stored = yatm_core.energy.receive_energy(meta, "energy_buffer", remaining, charge_bandwidth, capacity, true)
      consumed = consumed + stored
    end
    --print("CONSUMED", pos.x, pos.y, pos.z, node.name, "CONSUMED", consumed, "GIVEN", amount)
  end
  return consumed
end

function yatm_machines.worker_update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local meta = minetest.get_meta(pos, node)
    local total_available = yatm_core.energy.get_energy(meta, "energy_buffer")
    local ym = nodedef.yatm_network

    if ym.state == "off" then
      if total_available >= ym.startup_energy_threshold then
        ym.on_network_state_changed(pos, node, "on")
      end
    end

    if ym.state == "on" then
      local state = yatm_core.Network.get_network_state(meta)
      local capacity = ym.energy_capacity
      local bandwidth = ym.work_energy_bandwidth or capacity
      local thresh = ym.work_rate_energy_threshold
      local work_rate = 1.0
      if thresh and thresh > 0 then
        work_rate = total_available / thresh
      end
      local available_energy = yatm_core.energy.consume_energy(meta, "energy_buffer", bandwidth, bandwidth, capacity, false)
      local consumed = ym.work(pos, node, available_energy, work_rate)
      if consumed > 0 then
        yatm_core.energy.consume_energy(meta, "energy_buffer", consumed, bandwidth, capacity, true)
      end
    end

    local total_available = yatm_core.energy.get_energy(meta, "energy_buffer")
    if total_available == 0 then
      ym.on_network_state_changed(pos, node, "off")
    end
  end
end

function yatm_machines.default_on_network_state_changed(pos, node, state)
  local new_state = state
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network.state then
    if nodedef.yatm_network.state == "on" then
      -- it's currently on
      -- nothing to do
    else
      -- the intention is to activate the node
      if state == "on" then
        local meta = minetest.get_meta(pos, node)
        local total_available = yatm_core.energy.get_energy(meta, "energy_buffer")
        local threshold = nodedef.yatm_network.startup_energy_threshold
        print("TRY ONLINE", pos.x, pos.y, pos.z, node.name, total_available, threshold)
        if total_available < threshold then
          new_state = "off"
        end
      end
    end
  end
  yatm_core.Network.default_on_network_state_changed(pos, node, new_state)
end

function yatm_machines.register_network_device(name, nodedef)
  if not nodedef.on_yatm_device_changed then
    print("register_network_device", name, "patching register_network_device")
    nodedef.on_yatm_device_changed = assert(yatm_machines.default_on_device_changed)
  end

  if not nodedef.on_yatm_network_changed then
    print("register_network_device", name, "patching on_yatm_network_changed")
    nodedef.on_yatm_network_changed = assert(yatm_core.Network.default_handle_network_changed)
  end

  if nodedef.groups and nodedef.groups.yatm_network_host then
    if not nodedef.on_destruct then
      print("register_network_device", name, "patching on_destruct with on_host_destruct")
      nodedef.on_destruct = assert(yatm_core.Network.on_host_destruct)
    end
    if not nodedef.after_place_node then
      print("register_network_device", name, "patching after_place_node with default_yatm_notify_neighbours_changed")
      nodedef.after_place_node = assert(yatm_core.Network.device_after_place_node)
    end
  end

  if not nodedef.after_place_node then
    print("register_network_device", name, "patching after_place_node with device_after_place_node")
    nodedef.after_place_node = assert(yatm_machines.device_after_place_node)
  end

  if not nodedef.on_destruct then
    print("register_network_device", name, "patching on_destruct with on_host_destruct")
    nodedef.on_destruct = assert(yatm_machines.device_on_destruct)
  end

  if not nodedef.after_destruct then
    print("register_network_device", name, "patching after_destruct")
    nodedef.after_destruct = assert(yatm_machines.device_after_destruct)
  end

  if nodedef.yatm_network then
    local ym = nodedef.yatm_network
    if ym.on_network_state_changed == nil then
      ym.on_network_state_changed = assert(yatm_machines.default_on_network_state_changed)
    end
    if ym.groups then
      if ym.groups.machine_worker then
        ym.groups.has_update = 1
        ym.update = yatm_machines.worker_update

        assert(ym.energy_capacity, "workers require an energy capacity")
        assert(ym.network_charge_bandwidth, "workers require network charge bandwidth")
      end
      if ym.groups.energy_producer then
        assert(ym.produce_energy, "expected produce_energy/2 to be defined")
      end
      if ym.groups.energy_consumer then
        if ym.passive_energy_lost == nil then
          ym.passive_energy_lost = 10
        end
        if ym.consume_energy == nil then
          ym.consume_energy = yatm_machines.network_passive_consume_energy
        end
      end
    end
  end

  minetest.register_node(name, nodedef)
end

dofile(yatm_machines.modpath .. "/nodes.lua")
