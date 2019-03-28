local Network = assert(yatm_core.Network)

local devices = {
  ENERGY_BUFFER_KEY = "energy_buffer"
}

function devices.device_on_destruct(pos)
  return yatm.network.device_on_destruct(pos)
end

function devices.device_after_destruct(pos, node)
  return yatm.network.device_after_destruct(pos, node)
end

function devices.device_after_place_node(pos, placer, item_stack, pointed_thing)
  return yatm.network.device_after_place_node(pos, placer, item_stack, pointed_thing)
end

function devices.default_on_device_changed(pos, node, origin_pos, origin_node)
  print("devices.default_on_device_changed/4", pos.x, pos.y, pos.z, node.name, "ORIGIN", origin_pos.x, origin_pos.y, origin_pos.z, origin_node.name)
  yatm.network.schedule_refresh_network_topography(pos, {kind = "device_changed"})
end

--[[
@spec devices.device_passive_consume_energy(vector3.t, Node.t, non_neg_integer)
]]
function devices.device_passive_consume_energy(pos, node, amount)
  local consumed = 0
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.yatm_network then
    local ym = nodedef.yatm_network
    local energy = assert(ym.energy)
    -- Passive lost affects how much energy is available
    -- Passive lost will not affect the node's current buffer only the consumable amount
    local passive_lost = energy.passive_lost
    if passive_lost > 0 then
      consumed = consumed + math.min(amount, passive_lost)
    end
    local remaining = amount - consumed
    if remaining > 0 then
      local charge_bandwidth = energy.network_charge_bandwidth
      if charge_bandwidth and charge_bandwidth > 0 then
        local capacity = energy.capacity
        local meta = minetest.get_meta(pos)
        local stored = yatm.energy.receive_energy(meta, devices.ENERGY_BUFFER_KEY, remaining, charge_bandwidth, capacity, true)
        Network:queue_refresh_infotext(pos)
        consumed = consumed + stored
      end
    end
    --print("CONSUMED", pos.x, pos.y, pos.z, node.name, "CONSUMED", consumed, "GIVEN", amount)
  end
  return consumed
end

function devices.worker_update(pos, node, ot)
  --print("devices.worker_update/3", minetest.pos_to_string(pos), dump(node.name))
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local meta = minetest.get_meta(pos, node)
    local total_available = yatm.energy.get_energy(meta, devices.ENERGY_BUFFER_KEY)
    local ym = nodedef.yatm_network

    --print("Energy Available", total_available)
    if ym.state == "off" then
      if total_available >= ym.energy.startup_threshold then
        ym.on_network_state_changed(pos, node, "on")
      end
    end

    if ym.state == "on" then
      local state = yatm.network.get_network_state(meta)
      local capacity = ym.energy.capacity
      local bandwidth = ym.work_energy_bandwidth or capacity
      local thresh = ym.work_rate_energy_threshold
      local work_rate = 1.0
      if thresh and thresh > 0 then
        work_rate = total_available / thresh
      end
      local available_energy = yatm.energy.consume_energy(meta, devices.ENERGY_BUFFER_KEY, bandwidth, bandwidth, capacity, false)
      local consumed = ym.work(pos, node, available_energy, work_rate, ot)
      if consumed > 0 then
        yatm.energy.consume_energy(meta, devices.ENERGY_BUFFER_KEY, consumed, bandwidth, capacity, true)
        Network:queue_refresh_infotext(pos)
      end
      --print("devices.worker_update/3", minetest.pos_to_string(pos), dump(node.name), "consumed energy", consumed)
    end

    local total_available = yatm.energy.get_energy(meta, devices.ENERGY_BUFFER_KEY)
    if total_available == 0 then
      ym.on_network_state_changed(pos, node, "off")
    end
  end
end

function devices.default_on_network_state_changed(pos, node, state)
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
        if nodedef.yatm_network.groups.energy_consumer then
          local total_available = yatm.energy.get_energy(meta, devices.ENERGY_BUFFER_KEY)
          local threshold = nodedef.yatm_network.energy.startup_threshold or 0
          --print("TRY ONLINE", pos.x, pos.y, pos.z, node.name, total_available, threshold)
          if total_available < threshold then
            new_state = "off"
          end
        end
      end
    end
  end
  yatm.network.default_on_network_state_changed(pos, node, new_state)
end

function devices.register_network_device(name, nodedef)
  assert(name, "expected a name")
  assert(nodedef, "expected a nodedef")
  if not nodedef.on_yatm_device_changed then
    --print("register_network_device", name, "patching register_network_device")
    nodedef.on_yatm_device_changed = assert(devices.default_on_device_changed)
  end

  if not nodedef.on_yatm_network_changed then
    --print("register_network_device", name, "patching on_yatm_network_changed")
    nodedef.on_yatm_network_changed = assert(yatm.network.default_handle_network_changed)
  end

  if nodedef.groups and nodedef.groups.yatm_network_host then
    if not nodedef.on_destruct then
      --print("register_network_device", name, "patching on_destruct with on_host_destruct")
      nodedef.on_destruct = assert(yatm.network.on_host_destruct)
    end
    if not nodedef.after_place_node then
      --print("register_network_device", name, "patching after_place_node with default_yatm_notify_neighbours_changed")
      nodedef.after_place_node = assert(yatm.network.device_after_place_node)
    end
  end

  if not nodedef.after_place_node then
    --print("register_network_device", name, "patching after_place_node with device_after_place_node")
    nodedef.after_place_node = assert(devices.device_after_place_node)
  end

  if not nodedef.on_destruct then
    --print("register_network_device", name, "patching on_destruct with on_host_destruct")
    nodedef.on_destruct = assert(devices.device_on_destruct)
  end

  if not nodedef.after_destruct then
    --print("register_network_device", name, "patching after_destruct")
    nodedef.after_destruct = assert(devices.device_after_destruct)
  end

  if nodedef.yatm_network then
    assert(nodedef.yatm_network.kind, "all devices must have a kind (" .. name .. ")")
    local ym = nodedef.yatm_network
    if ym.on_network_state_changed == nil then
      ym.on_network_state_changed = assert(devices.default_on_network_state_changed)
    end
    if ym.groups then
      if ym.groups.machine_worker then
        ym.groups.has_update = 1
        ym.update = devices.worker_update

        assert(ym.state, name .. " a machine_worker must have a `state`")
        assert(ym.energy, name .. " a machine_worker requires an `energy` interface containing all energy behaviour")
        assert(ym.energy.capacity, name .. " a machine_worker requires an `energy.capacity`")
        assert(ym.energy.network_charge_bandwidth, name .. " a machine_worker require `energy.network_charge_bandwidth`")
        assert(ym.energy.startup_threshold, name .. " a machine_worker requires a `energy.startup_threshold`")
        assert(ym.work, name .. " a machine_worker requries a `work/5` function")
      end
      if ym.groups.has_update then
        assert(ym.update, "expected update/3 to be defined")
      end
      if ym.groups.energy_producer then
        assert(ym.energy, name .. " energy_producer requires an `energy` interface containing all energy behaviour")
        assert(ym.energy.produce_energy, "expected produce_energy/2 to be defined")
      end
      if ym.groups.energy_consumer then
        assert(ym.energy, name .. " energy_consumer requires an `energy` interface containing all energy behaviour")
        if ym.energy.passive_lost == nil then
          ym.energy.passive_lost = 10
        end
        if ym.energy.consume_energy == nil then
          ym.energy.consume_energy = assert(devices.device_passive_consume_energy)
        end
      end
      if ym.groups.energy_storage then
        assert(ym.energy, name .. " energy_storage requires an `energy` interface")
        assert(ym.energy.get_usable_stored_energy, name .. " expected a `get_usable_stored_energy` function to be defined")
        assert(ym.energy.use_stored_energy, name .. " expected a `use_stored_energy` function to be defined")
      end
      if ym.groups.energy_receiver then
        assert(ym.energy, name .. " energy_receiver requires an `energy` interface")
        assert(ym.energy.receive_energy, name .. " expected a receive_energy function to be defined")
      end
    end
  end

  return minetest.register_node(name, nodedef)
end

function devices.register_stateful_network_device(base_node_def, overrides)
  overrides = overrides or {}
  assert(base_node_def, "expected a nodedef")
  assert(base_node_def.yatm_network, "expected a yatm_network")
  assert(base_node_def.yatm_network.states, "expected a yatm_network.states")
  assert(base_node_def.yatm_network.default_state, "expected a yatm_network.default_state")

  local seen = {}

  for state,name in pairs(base_node_def.yatm_network.states) do
    if not seen[name] then
      seen[name] = true

      local ov = overrides[state]
      if state == "conflict" and not ov then
        state = "error"
        ov = overrides[state]
      end
      ov = ov or {}
      local node_def = yatm_core.table_deep_merge(base_node_def, ov)
      local new_yatm_network = yatm_core.table_merge(node_def.yatm_network, {state = state})
      node_def.yatm_network = new_yatm_network

      if node_def.yatm_network.default_state ~= state then
        local groups = yatm_core.table_merge(node_def.groups, {not_in_creative_inventory = 1})
        node_def.groups = groups
      end

      devices.register_network_device(name, node_def)
    end
  end
end

yatm.devices = devices
