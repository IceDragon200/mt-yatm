local table_merge = assert(foundation.com.table_merge)
local table_deep_merge = assert(foundation.com.table_deep_merge)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)

local devices = {
  ENERGY_BUFFER_KEY = "energy_buffer"
}

function devices.device_on_construct(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.groups['yatm_cluster_device'] then
    cluster_devices:schedule_add_node(pos, node)
  end

  if nodedef.groups['yatm_cluster_energy'] then
    cluster_energy:schedule_add_node(pos, node)
  end
end

function devices.device_on_destruct(pos)
  --
end

function devices.device_after_destruct(pos, old_node)
  local nodedef = minetest.registered_nodes[old_node.name]
  if nodedef.groups['yatm_cluster_device'] then
    cluster_devices:schedule_remove_node(pos, old_node)
  end
  if nodedef.groups['yatm_cluster_energy'] then
    cluster_energy:schedule_remove_node(pos, old_node)
  end
end

function devices.device_after_place_node(pos, placer, item_stack, pointed_thing)
  --
end

function devices.device_transition_device_state(pos, node, state)
  --print("yatm_machines", "device_transition_device_state", minetest.pos_to_string(pos), "node=" .. node.name, "state=" .. state)

  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.yatm_network.states then
    local new_node_name

    if state == "down" then
      new_node_name = nodedef.yatm_network.states['off']
    elseif state == "up" then
      if nodedef.state == "idle" then
        new_node_name = nodedef.yatm_network.states['idle']
      else
        new_node_name = nodedef.yatm_network.states['on']
      end
    elseif state == "conflict" then
      new_node_name = nodedef.yatm_network.states['conflict']
    else
      error("unhandled state=" .. state)
    end
    if new_node_name then
      node = minetest.get_node(pos)

      if node.name ~= new_node_name then
        node.name = new_node_name
        minetest.swap_node(pos, node)

        if nodedef.groups['yatm_cluster_device'] then
          cluster_devices:schedule_update_node(pos, node)
        end

        if nodedef.groups['yatm_cluster_energy'] then
          cluster_energy:schedule_update_node(pos, node)
        end
      end
    end

    yatm.queue_refresh_infotext(pos, node)
  end
end

function devices.get_energy_capacity(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  local en = nodedef.yatm_network.energy

  if type(en.capacity) == "number" then
    return en.capacity
  elseif type(en.capacity) == "function" then
    return en.capacity(pos, node)
  else
    return 0
  end
end

--
-- @spec devices.device_passive_consume_energy(vector3.t, Node.t, non_neg_integer, float, TraceContext)
--
function devices.device_passive_consume_energy(pos, node, total_available, dtime, ot)
  local span = ot:span_start("device_passive_consume_energy")
  local consumed = 0
  local nodedef = minetest.registered_nodes[node.name]
  local energy = nodedef.yatm_network.energy
  local capacity = devices.get_energy_capacity(pos, node)

  -- Passive lost affects how much energy is available
  -- Passive lost will not affect the node's current buffer only the consumable amount
  local passive_lost = energy.passive_lost
  if passive_lost > 0 then
    consumed = consumed + math.min(total_available, passive_lost)
  end

  local remaining = total_available - consumed
  if remaining > 0 then
    local charge_bandwidth = energy.network_charge_bandwidth

    if charge_bandwidth and charge_bandwidth > 0 then
      local meta = minetest.get_meta(pos)
      local stored = yatm.energy.receive_energy(meta, devices.ENERGY_BUFFER_KEY, remaining, charge_bandwidth, capacity, true)

      consumed = consumed + stored

      yatm.queue_refresh_infotext(pos, node)
    end
  end

  --print("CONSUMED", pos.x, pos.y, pos.z, node.name, "CONSUMED", consumed, "GIVEN", total_available)
  span:span_end()

  return consumed
end

function devices.set_idle(meta, duration_sec)
  meta:set_float("idle_time", duration_sec)
end

function devices.worker_update(pos, node, dtime, ot)
  --print("devices.worker_update/3", minetest.pos_to_string(pos), dump(node.name))
  local nodedef = minetest.registered_nodes[node.name]
  local meta = minetest.get_meta(pos, node)

  local total_available = yatm.energy.get_energy(meta, devices.ENERGY_BUFFER_KEY)
  local ym = assert(nodedef.yatm_network)

  --print("Energy Available", total_available)
  if ym.state == "off" then
    if total_available >= ym.energy.startup_threshold then
      ym.on_network_state_changed(pos, node, "on")
    end
  end

  if ym.state == "on" then
    local idle_time = meta:get_float("idle_time")
    idle_time = math.max(0, idle_time - dtime)

    meta:set_float("idle_time", idle_time)

    if idle_time <= 0 then
      local capacity = devices.get_energy_capacity(pos, node)
      local bandwidth = ym.work_energy_bandwidth or capacity
      local work_rate = 1.0

      local thresh = ym.work_rate_energy_threshold
      if thresh and thresh > 0 then
        work_rate = total_available / thresh
      end

      local available_energy = yatm.energy.consume_energy(meta, devices.ENERGY_BUFFER_KEY, bandwidth, bandwidth, capacity, false)
      local consumed = ym.work(pos, node, available_energy, work_rate, dtime, ot)

      if consumed > 0 then
        yatm.energy.consume_energy(meta, devices.ENERGY_BUFFER_KEY, consumed, bandwidth, capacity, true)
        yatm.queue_refresh_infotext(pos, node)
      end
      --print("devices.worker_update/3", minetest.pos_to_string(pos), dump(node.name), "consumed energy", consumed)
    else
      yatm.queue_refresh_infotext(pos, node)
    end
  end

  total_available = yatm.energy.get_energy(meta, devices.ENERGY_BUFFER_KEY)
  if total_available == 0 then
    ym.on_network_state_changed(pos, node, "off")
  end
end

local function network_default_on_network_state_changed(pos, node, state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network.states then
    local new_name = assert(nodedef.yatm_network.states[state], "expected node=" .. node.name .. " to have a state=" .. state)
    if node.name ~= new_name then
      --debug("node", "NETWORK CHANGED", minetest.pos_to_string(pos), node.name, "STATE", state)
      node.name = new_name
      minetest.swap_node(pos, node)
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
  network_default_on_network_state_changed(pos, node, new_state)
end

function devices.patch_device_nodedef(name, nodedef)
  assert(name, "expected a node name")
  assert(nodedef, "expected a nodedef")

  nodedef.groups = nodedef.groups or {}
  nodedef.groups['yatm_cluster_device'] = 1

  if nodedef.transition_device_state == nil then
    --print("register_network_device", name, "using device_transition_device_state")
    nodedef.transition_device_state = assert(devices.device_transition_device_state)
  end

  if nodedef.after_place_node == nil then
    --print("register_network_device", name, "using device_after_place_node")
    nodedef.after_place_node = assert(devices.device_after_place_node)
  end

  if nodedef.on_construct == nil then
    --print("register_network_device", name, "using device_on_construct")
    nodedef.on_construct = assert(devices.device_on_construct)
  end

  if nodedef.on_destruct == nil then
    --print("register_network_device", name, "using device_on_destruct")
    nodedef.on_destruct = assert(devices.device_on_destruct)
  end

  if nodedef.after_destruct == nil then
    --print("register_network_device", name, "using device_after_destruct")
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
        assert(ym.work, name .. " a machine_worker requries a `work/6` function")
      end

      if ym.groups.has_update then
        assert(ym.update, "expected update/3 to be defined")
      end

      if ym.groups.energy_producer then
        assert(ym.energy, name .. " energy_producer requires an `energy` interface containing all energy behaviour")
        assert(ym.energy.produce_energy, "expected produce_energy/4 to be defined")

        nodedef.groups['yatm_cluster_energy'] = 1
      end

      if ym.groups.energy_consumer then
        assert(ym.energy, name .. " energy_consumer requires an `energy` interface containing all energy behaviour")
        if ym.energy.passive_lost == nil then
          ym.energy.passive_lost = 10
        end
        if ym.energy.consume_energy == nil then
          ym.energy.consume_energy = assert(devices.device_passive_consume_energy)
        end

        nodedef.groups['yatm_cluster_energy'] = 1
      end

      if ym.groups.energy_storage then
        assert(ym.energy, name .. " energy_storage requires an `energy` interface")
        assert(ym.energy.get_usable_stored_energy, name .. " expected a `get_usable_stored_energy` function to be defined")
        assert(ym.energy.use_stored_energy, name .. " expected a `use_stored_energy` function to be defined")
        nodedef.groups['yatm_cluster_energy'] = 1
      end

      if ym.groups.energy_receiver then
        assert(ym.energy, name .. " energy_receiver requires an `energy` interface")
        assert(ym.energy.receive_energy, name .. " expected a receive_energy function to be defined")
        nodedef.groups['yatm_cluster_energy'] = 1
      end
    end
  end

  return nodedef
end

function devices.register_network_device(name, nodedef)
  assert(name, "expected a name")

  devices.patch_device_nodedef(name, nodedef)

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
      local node_def = table_deep_merge(base_node_def, ov)
      local new_yatm_network = table_merge(node_def.yatm_network, {state = state})
      node_def.yatm_network = new_yatm_network

      if node_def.yatm_network.default_state ~= state then
        local groups = table_merge(node_def.groups, {not_in_creative_inventory = 1})
        node_def.groups = groups
      end

      devices.register_network_device(name, node_def)
    end
  end
end

yatm.devices = devices

yatm.grinding = yatm.grinding or {}
yatm.grinding.grinding_registry = yatm_machines.GrindingRegistry:new()

yatm.freezing = yatm.freezing or {}
yatm.freezing.freezing_registry = yatm_machines.FreezingRegistry:new()

yatm.condensing = yatm.condensing or {}
yatm.condensing.condensing_registry = yatm_machines.CondensingRegistry:new()

yatm.compacting = yatm.compacting or {}
yatm.compacting.compacting_registry = yatm_machines.CompactingRegistry:new()

yatm.rolling = yatm.rolling or {}
yatm.rolling.rolling_registry = yatm_machines.RollingRegistry:new()

yatm.crushing = yatm.crushing or {}
yatm.crushing.crushing_registry = yatm_machines.CrushingRegistry:new()
